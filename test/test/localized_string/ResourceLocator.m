//
//  ResourceLocator.m
//  test
//
//  Created by 李威 on 2021/5/10.
//  Copyright © 2021 李威. All rights reserved.
//

#import "ResourceLocator.h"
#import "HTMLDecode.h"
#import "framework/CHCSVParser.h"
#import "LocalizableDelegate.h"

@interface ResourceLocator()
@property (nonatomic, copy) NSString *bundleName;
@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) NSBundle *mainBundle;
@property (nonatomic, copy) NSString *languageCode;
@property (nonatomic, strong) HTMLDecode *htmldecode;
@property (nonatomic, strong) NSDictionary *languageAdjust;
@property (nonatomic,strong) NSDictionary *languageAdjust_fr;
@property (nonatomic,strong) NSDictionary *languageAdjust_de;
@property (nonatomic,strong) NSDictionary *languageAdjust_ru;

///当前选择国家的国际化文案
@property (nonatomic, strong) NSMutableDictionary *currentLocalizable;
///当前系统语言国际化文案
///(为了兼容app内切换国家与系统语言不一致时获取本地化文案不对的问题)
@property (nonatomic, strong) NSMutableDictionary *currentSystemLocalizable;
@end

@implementation ResourceLocator
+ (instancetype)shareInstace {
    static dispatch_once_t onceToken;
    static ResourceLocator *instance;
    dispatch_once(&onceToken, ^{
        instance = [[ResourceLocator alloc]init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        //多个工程时需要设置一下
        _mainBundle = [NSBundle mainBundle];
        self.htmldecode = [[HTMLDecode alloc]init];
        
        //解析plist文件
        NSString *plistPath = [self.mainBundle pathForResource:@"Language_adjust" ofType:@"plist"];
        if (plistPath) {
            NSData *propertyListData = [NSData dataWithContentsOfFile:plistPath];
            if (propertyListData) {
                //plist解析
                self.languageAdjust = [NSPropertyListSerialization propertyListWithData:propertyListData options:NSPropertyListImmutable format:nil error:nil];
            }
        }
        //法语
        NSString *plistPath_fr = [self.mainBundle pathForResource:@"Language_adjust_fr" ofType:@"plist"];
        if (plistPath_fr) {
            NSData *propertyListData_fr = [NSData dataWithContentsOfFile:plistPath_fr];
            if (propertyListData_fr) {
                self.languageAdjust_fr = [NSPropertyListSerialization propertyListWithData:propertyListData_fr options:0 format:nil error:nil];
            }
        }
        //德语
        NSString *plistPath_de = [_mainBundle pathForResource:@"Language_adjust_de" ofType:@"plist"];
        if (plistPath_de) {
            NSData *propertyListData_de = [NSData dataWithContentsOfFile:plistPath_de];
            if (propertyListData_de) {
                self.languageAdjust_de = [NSPropertyListSerialization propertyListWithData:propertyListData_de options:0 format:nil error:nil];
            }
        }
        //俄语
        NSString *plistPath_ru = [_mainBundle pathForResource:@"Language_adjust_ru" ofType:@"plist"];
        if (plistPath_de) {
            NSData *propertyListData_ru = [NSData dataWithContentsOfFile:plistPath_ru];
            if (propertyListData_ru) {
                self.languageAdjust_ru = [NSPropertyListSerialization propertyListWithData:propertyListData_ru options:0 format:nil error:nil];
            }
        }
    }
    return self;
}

#pragma mark - 更新国家、 csv文件处理
//根据当前国家LanguageCode 和csv文件 生成国际化文案字典
- (BOOL)updateWithLanguage:(NSString *)languageCode fileName:(NSString *)fileName {
    if ([_languageCode isEqualToString:languageCode]) {
        return NO;
    }
    _languageCode = languageCode;
    NSArray *result = [self parseCSVFile:fileName];
    [self analysisResult:result language:languageCode followSystemLanguage:NO];
    
    NSString *systemLanguageCode = [[NSLocale preferredLanguages].firstObject componentsSeparatedByString:@"-"].firstObject;
    if (![systemLanguageCode isEqualToString:languageCode]) {//系统语言与当前国家不一致需要单独解析
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self analysisResult:result language:systemLanguageCode followSystemLanguage:YES];
        });
    } else {
        _currentSystemLocalizable = _currentLocalizable;
    }
    
    //如果语言是德国 则加入新版翻译 如有相同条目覆盖旧的
    if ([_languageCode isEqualToString:@"de"]) {
        NSArray *german_result = [self parseCSVFile:@"Language_German.csv"];
        [self analysisGermanResult:german_result serialNumber:3];
    }
    
    //如果语言是德国 则加入新版翻译 如有相同条目覆盖旧的
    if ([_languageCode isEqualToString:@"ru"]) {
        NSArray *russian_result = [self parseCSVFile:@"Language_Russian.csv"];
        [self analysisGermanResult:russian_result serialNumber:4];
    }
    
    return YES;
}

//分析初步parse出的NSArray 整理出国际化文案
//1.首先第一行生成支持国际化的国家代码
//2.生成对应的国家的 国际化字典 {@"key":@"国际化文案"}; 英文做key
//3.其中字符串开头为{的为复数格式 以{@"key":@{@"one":@"...",@"many":@"..."}};形式保存
- (BOOL)analysisResult:(NSArray *)lines language:(NSString *)language followSystemLanguage:(BOOL)followSystemLanguage {
    if (!lines.count || !language.length) {
        return NO;
    }
    
    NSString *targetLanguage = language;
    NSMutableArray *languages = [NSMutableArray array];//存储国家
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    [resultDict setObject:targetLanguage forKey:@"language"];
    
    //csv文件第一行3列开始是国家code：i=3
    NSArray *line0 = lines[0];//所有国家code
    NSInteger serialNumber = 0;//搜索的语言code对应的列
    for (NSInteger i=3; i<line0.count; i++) {
        NSString *str = [line0 objectAtIndex:i];
        [languages addObject:str];
        if ([str isEqualToString:targetLanguage]) {
            serialNumber = i;
        }
    }
    
    if (serialNumber==0) {
        if (followSystemLanguage) {
            _currentSystemLocalizable = resultDict.mutableCopy;
        } else {
            _currentLocalizable = resultDict.mutableCopy;
        }
        return NO;
    }
    
    for (NSInteger i=1; i<lines.count; i++) {//从1开始，0是国家code已经处理
        @autoreleasepool {
            NSArray *array = lines[i];
            //array.count > serialNumber  ？
            if (array.count > serialNumber && array.count>2) {
                //处理key
                NSString *key = array[2];
                if (key.length==0) {//key为空
                    continue;
                }
                
                if (![key hasPrefix:@"{"]) {
                    key = [self transformHavePHString:key];// \<ph />标签改成：@
                    if([key rangeOfString:@"&"].location != NSNotFound){
                        key = [self decodeHtmlString:key];
                    }
                    key = [self cleanStr:key];
                }else{
                    key = [self keyOfPluralString:key];//复数形式的key
                }
                
                //逐行处理相应国家serialNumber列对应的value
                if (key && key.length) {
                    NSString *string = array[serialNumber];//相应国家的value
                    if (![string hasPrefix:@"{"]) {
                        string = [self transformHavePHString:string];
                        if([string rangeOfString:@"&"].location != NSNotFound){
                            string = [self decodeHtmlString:string];
                        }
                        string = [self cleanStr:string];
                        [resultDict setObject:string?:@"" forKey:key];
                    }else {
                        NSDictionary *dic = [self transformHavePluralString:string];//复数形式的value
                        if (dic) {
                            [resultDict setValue:dic forKey:key];
                        }
                    }
                    
                }
            }
        }
    }
    return NO;
}

-(BOOL)analysisGermanResult:(NSArray *)lines serialNumber:(NSInteger)serialNumber{
    if (!lines.count) {
        return NO;
    }
    if (serialNumber < 0) {
        serialNumber = 3;
    }
    for(NSInteger i = 1;i < lines.count;i++){
        @autoreleasepool{
            NSArray *array = lines[i];
            if (array.count > serialNumber && array.count > 2) {
                NSString *key = array[2];
                if (key.length == 0) {
                    continue;
                }
    //            if ([key rangeOfString:@"%1$s"].location != NSNotFound) {
    //                NSLog(@"key==>%@",key);
    //            }
                if (![key hasPrefix:@"{"]) {
                    key = [self transformHavePHString:key];
                    if([key rangeOfString:@"&"].location != NSNotFound){
                        key = [self decodeHtmlString:key];
                    }
                    key = [self cleanStr:key];
                }else{
                    key = [self keyOfPluralString:key];
                }

                if (key && key.length) {
                    NSString *string = array[serialNumber];
                    if (![string hasPrefix:@"{"]) {
                        string = [self transformHavePHString:string];
                        if([string rangeOfString:@"&"].location != NSNotFound){
                            string = [self decodeHtmlString:string];
                        }
                        string = [self cleanStr:string];
                        [_currentLocalizable setObject:string?:@"" forKey:key];
                    }else {
                        NSDictionary *dic = [self transformHavePluralString:string];
                        if (dic) {
                            [_currentLocalizable setValue:dic forKey:key];
                        }
                    }
                }
            }
        }
    }
#ifdef DEBUG
//    NSLog(@"%@",_currentLocalizable);
#endif
    return YES;
}

#pragma mark - 搜索文案

- (NSString *)localizedStringForKey:(NSString *)key withPlural:(NSString *)plural {
    return [self localizedStringForKey:key withPlural:plural usingSystemLanguage:NO];
}
/*
 //通过key找到国际化文案
 // 1.首先通过 Localizable.strings 找对应英文文案 作为key
 // 2.然后去_currentLocalizable查找key对应的 国际化文案
 // 3.@plural 当有复数情况时候(以dictionary存储) "0"或"1":返回单数文案  其他:返回复数文案
 // 4.整理文案 如有&转码 清理<blod>
 // 5.最后根据自定义plist 最后修改文案
 */
- (NSString *)localizedStringForKey:(NSString *)key withPlural:(NSString *)plural usingSystemLanguage:(BOOL)usingSystemLanguage {
    /*系统国际化宏调用的方法,获取localized文件相应key的value*/
    NSString *localizedString = [[NSBundle mainBundle] localizedStringForKey:key value:@"" table:nil];
    
    NSMutableDictionary *sourceDict = usingSystemLanguage?_currentSystemLocalizable:_currentLocalizable;
    if (sourceDict || localizedString.length) {
        NSString *str = [sourceDict objectForKey:localizedString];
        if ([str isKindOfClass:[NSString class]]) {
            if (str.length) {
                localizedString = str;
            }
        } else if ([str isKindOfClass:[NSDictionary class]]) {///处理复数形式
            /*复数以字典存储
             {VIDEOS, plural,
             one {<ph name="COUNT" /> new video}
             few {<ph name="COUNT" /> new videos}
             many {<ph name="COUNT" /> new videos}
             other {<ph name="COUNT" /> new videos}}*/
            NSDictionary *dict = (NSDictionary *)str;
            if ([plural isEqualToString:@"0"] || [plural isEqualToString:@"1"]) {
                localizedString = [dict objectForKey:@"one"];
            } else {
                localizedString = [dict objectForKey:@"many"];
            }
        }
    }
    //字符串处理
    if ([localizedString rangeOfString:@"&"].location != NSNotFound) {
        localizedString = [self decodeHtmlString:localizedString];
    }
    localizedString = [self cleanStr:localizedString];
    
    /*
     NSString *languageCode = [[NSLocale currentLocale]objectForKey:NSLocaleLanguageCode];
     //英语添加小手：适配文字过长位置不对bug
     BOOL showHand = [languageCode isEqualToString:@"en"] || [languageCode isEqualToString:@"fr"];
     */
    //获取language code
    NSString *systemLanguageCode = [[NSLocale preferredLanguages].firstObject componentsSeparatedByString:@"-"].firstObject;
    NSString *languageCode = usingSystemLanguage?systemLanguageCode:self.languageCode;
    
    if (!localizedString.length) {
        return localizedString;
    }
    
    if ([languageCode isEqualToString:@"fr"] && self.languageAdjust_fr) {
        NSString *adjustString_fr = [self.languageAdjust_fr objectForKey:localizedString];
        if (adjustString_fr && adjustString_fr.length) {
            localizedString = adjustString_fr;
        }
    } else if ([languageCode isEqualToString:@"de"] && self.languageAdjust_de) {
        NSString *adjustString_de = [self.languageAdjust_de objectForKey:localizedString];
        if (adjustString_de && adjustString_de.length) {
            localizedString = adjustString_de;
        }
    } else if ([languageCode isEqualToString:@"ru"] && self.languageAdjust_ru) {
        NSString *adjustString_ru = [self.languageAdjust_ru objectForKey:localizedString];
        if (adjustString_ru && adjustString_ru.length) {
            localizedString = adjustString_ru;
        }
    }
    
    if (localizedString.length) {
        NSString *adjustString = [self.languageAdjust objectForKey:localizedString];
        if (adjustString.length && adjustString) {
            localizedString = adjustString;
        }
    }
    return localizedString;
}

#pragma mark - 字符串处理

//输出复数格式相应key
-(NSString *)keyOfPluralString:(NSString *)key{
    NSRange begin_one = [key rangeOfString:@"one {"];
    if (begin_one.location == NSNotFound) {
        begin_one = [key rangeOfString:@"one{"];
        if (begin_one.location == NSNotFound) {
           return nil;
        }
    }
    NSRange end_one = [key rangeOfString:@"}"];
    if (end_one.location == NSNotFound) {
       return nil;
    }
    NSRange oneRang;
    if (end_one.location < begin_one.location + begin_one.length) {
//        NSLog(@"小于零了~");//即将出错
        end_one = [key rangeOfString:@"}" options:NSCaseInsensitiveSearch range:NSMakeRange(begin_one.location, key.length - begin_one.location)];
    }
    oneRang.location = begin_one.location + begin_one.length;
    oneRang.length = MAX(end_one.location - begin_one.location - begin_one.length,0);
    NSString *str_one = [key substringWithRange:oneRang];
    if ([str_one rangeOfString:@"<ph"].location != NSNotFound) {
        str_one = [self transformHavePHString:str_one];
    }
    str_one = [self cleanStr:str_one];
    return str_one;
}

//输出复数格式相应文案
-(NSMutableDictionary *)transformHavePluralString:(NSString *)phString{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSRange begin_one = [phString rangeOfString:@"one {"];
    if (begin_one.location == NSNotFound) {
        begin_one = [phString rangeOfString:@"one{"];
        if (begin_one.location == NSNotFound) {
           return dic;
        }
    }
    NSRange end_one = [phString rangeOfString:@"}"];
    if (end_one.location == NSNotFound) {
       return dic;
    }
    if (end_one.location < begin_one.location + begin_one.length) {
//        NSLog(@"小于零了~");//即将出错
        end_one = [phString rangeOfString:@"}" options:NSCaseInsensitiveSearch range:NSMakeRange(begin_one.location, phString.length - begin_one.location)];
    }
    NSRange oneRang;
    oneRang.location = begin_one.location + begin_one.length;
    oneRang.length = MAX(end_one.location - begin_one.location - begin_one.length,0);
    NSString *str_one = [phString substringWithRange:oneRang];
    if ([str_one rangeOfString:@"<ph"].location != NSNotFound) {
        str_one = [self transformHavePHString:str_one];
    }
    if (str_one) {
        str_one = [self cleanStr:str_one];
        [dic setValue:str_one forKey:@"one"];
    }
    
    NSRange begin_many = [phString rangeOfString:@"many {"];
    if (begin_many.location == NSNotFound) {
        begin_many = [phString rangeOfString:@"many{"];
        if (begin_many.location == NSNotFound) {
           return dic;
        }
    }
    NSRange end_many = [phString rangeOfString:@"}" options:NSCaseInsensitiveSearch range:NSMakeRange(begin_many.location+begin_many.length, phString.length-(begin_many.location+begin_many.length))];
    if (end_many.location == NSNotFound) {
       return dic;
    }
    NSRange manyRang;
    manyRang.location = begin_many.location + begin_many.length;
    manyRang.length = MAX(end_many.location - begin_many.location - begin_many.length,0);
    NSString *str_many = [phString substringWithRange:manyRang];
    if ([str_many rangeOfString:@"<ph"].location != NSNotFound) {
        str_many = [self transformHavePHString:str_many];
    }
    if (str_many) {
        str_many = [self cleanStr:str_many];
        [dic setValue:str_many forKey:@"many"];
    }
    return dic;
}

/*
 //Заощаджено <ph name="BEGIN_TAG" />80%<ph name="END_TAG" />
 //转换为 Заощаджено %@80%%@
 //所有ph标签 替换为%@
 */
-(NSString *)transformHavePHString:(NSString *)phString{
    NSRange begin = [phString rangeOfString:@"<ph"];
    NSRange end = [phString rangeOfString:@"/>"];
    if(!phString || begin.location == NSNotFound || end.location == NSNotFound){
        return phString;
    }
    begin.length = end.location + end.length - begin.location;
    phString = [phString stringByReplacingCharactersInRange:begin withString:@"%@"];
    if ([phString rangeOfString:@"<ph"].location != NSNotFound) {
        phString = [self transformHavePHString:phString];
    }
    return phString;
}

- (NSString *)decodeHtmlString:(NSString *)string {
    NSString *str = [self.htmldecode decodeString:string];
    str = [str stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    return str;
}

-(NSString *)cleanStr:(NSString *)str{
    str = [str stringByReplacingOccurrencesOfString:@"<bold>" withString:@""];//去掉字体
    str = [str stringByReplacingOccurrencesOfString:@"</bold>" withString:@""];//去掉字体
    str = [str stringByReplacingOccurrencesOfString:@"%1$d" withString:@"%@"];//去掉安卓数字相关
    str = [str stringByReplacingOccurrencesOfString:@"%1$s" withString:@"%@"];//去掉安卓数字相关
    return str;
}

#pragma mark - 解析

//parseCSVFile 生成以行为单位的 NSArray<NSArray *>*  保存在[d lines];
- (NSArray *)parseCSVFile:(NSString *)fileName {
    NSString *filePath = [self.mainBundle pathForResource:fileName.stringByDeletingPathExtension ofType:fileName.pathExtension];
    NSStringEncoding encoding = 0;
    NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath:filePath];
    CHCSVParser *p = [[CHCSVParser alloc]initWithInputStream:stream usedEncoding:&encoding delimiter:','];
    [p setRecognizesBackslashesAsEscapes:YES];
    [p setSanitizesFields:YES];
    
    LocalizableDelegate *delegate = [[LocalizableDelegate alloc]init];
    [p setDelegate:delegate];
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    [p parse];
    NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
    
    NSLog(@"raw difference: %f", (end-start));
    return [delegate result];
}

@end
