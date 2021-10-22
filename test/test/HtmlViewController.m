//
//  HtmlViewController.m
//  test
//
//  Created by 李威 on 2020/2/26.
//  Copyright © 2020 李威. All rights reserved.
//

#import "HtmlViewController.h"
#import <WebKit/WebKit.h>

@interface HtmlViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *webView;

@end

@implementation HtmlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *urlPath = @"/Users/liwei/bbbb.html";
    [_webView loadFileURL:[NSURL URLWithString:urlPath] allowingReadAccessToURL:[NSURL URLWithString:@"/Users/liwei"]];
}

@end
