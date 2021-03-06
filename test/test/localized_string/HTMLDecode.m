// ReallyFastHTMLDecode (TM)
// Copyright (C) 2013 by David Hoerl
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "HTMLDecode.h"

static NSDictionary *namedEntities(void);

static NSDictionary *translationDict;

static NSCharacterSet *alphaSet;
static NSCharacterSet *alphaNumSet;

//#if
//#define LOG NSLog
//#else
//#define LOG(x, ...)
//#endif

@interface HTMLDecode ()
@end

@implementation HTMLDecode

+ (void)initialize
{
	if(self == [HTMLDecode class]) {
		translationDict = namedEntities();
		
		NSMutableCharacterSet *cs;
		
		cs = [NSMutableCharacterSet characterSetWithRange:NSMakeRange('a', 26)];
		[cs formUnionWithCharacterSet:[NSCharacterSet characterSetWithRange:NSMakeRange('A', 26)]];
		alphaSet = [cs copy];
		
		cs = [NSMutableCharacterSet decimalDigitCharacterSet];
		[cs formUnionWithCharacterSet:alphaSet];
		alphaNumSet = [cs copy];
	}
}

- (NSString *)decodeData:(NSData *)data
{
	const uint8_t *ptr		= [data bytes];
	NSUInteger len			= [data length];
	const uint8_t *endPtr	= ptr + (len ? (len-1) : 0);	// need one char lookahead

	NSString *str = [[NSString alloc] initWithBytes:(void *)[data bytes] length:[data length] encoding:NSUTF8StringEncoding];	
	while(ptr != endPtr) {
		if(ptr[0] == '&' && ptr[1] != ' ') break;			// common case of & and no encoding
		++ptr;
	}
	if(ptr == endPtr) return str;

	str = [self decodeString:str];
	return str;
}

- (NSString *)decodeString:(NSString *)str
{
	NSArray *atArray = [str componentsSeparatedByString:@"&"];
	NSMutableArray *chunkArray = [NSMutableArray arrayWithCapacity:[atArray count]];
	
	// Preload the chunks to have the appropriate size of the receiver
	[atArray enumerateObjectsUsingBlock:^(NSString *chunk, NSUInteger idx, BOOL *stop)
		{
			[chunkArray addObject:[NSMutableString stringWithCapacity:[chunk length]+1]];	// +1 for '&'
		} ];	

	[atArray enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSString *chunk, NSUInteger idx, BOOL *stop)
		{
			NSMutableString *newChunk = chunkArray[idx];
			//NSUInteger chunkLen = [chunk length];
			//NSUInteger chunkLenM1 = chunkLen - 1;
			BOOL useOriginal = YES;

			// smallest possible is "#38;"
			if(idx == 0 || [chunk length] < 4) {
				if(idx) [newChunk appendString:@"&"];
				[newChunk appendString:chunk];
				return;
			}

			unichar c = [chunk characterAtIndex:0];
			switch(c) {
			case ' ':
				break;
			
			case '#':
			{
				// Number
				BOOL isHex = [chunk characterAtIndex:1] == 'x';
				NSScanner *scanner = [NSScanner scannerWithString:chunk];
				[scanner scanString:isHex ? @"#x" : @"#" intoString:NULL];	// skip prefix

				int i = 0;
				BOOL success = isHex ? [scanner scanHexInt:(unsigned int *)&i] : [scanner scanInt:&i];

				if(success && i > 0 && i <= 0xFFFD && [scanner scanString:@";" intoString:NULL]) {
					unichar tc = (unichar)i;
//					LOG(@"Numeric Code: tc=%d", (int)tc);
					[newChunk appendFormat:@"%C%@", tc, [chunk substringFromIndex:[scanner scanLocation]]];
					useOriginal = NO;
				} else {
//					LOG(@"BAD Numeric Code: tc=%u", i);
				}
			}
			
			default:
				if([alphaSet characterIsMember:c]) {
					NSScanner *scanner = [NSScanner scannerWithString:chunk];

					__autoreleasing NSString *name;
					[scanner scanCharactersFromSet:alphaNumSet intoString:&name];	// has to succeed since know the first char is valid
					
					NSString *translation = (NSString *)translationDict[name];
					if(translation && [scanner scanString:@";" intoString:NULL]) {
						[newChunk appendFormat:@"%@%@", translation, [chunk substringFromIndex:[scanner scanLocation]]];
//						LOG(@"Character Code: key=%@ value=%@ leftover=%@", name, translation, [chunk substringFromIndex:[scanner scanLocation]]);
						useOriginal = NO;
					}
				}
				break;
			}
			if(useOriginal) {
				[newChunk appendFormat:@"&%@", chunk];
			}
		} ];
		
	return [chunkArray componentsJoinedByString:@""];
}

@end

static NSDictionary *namedEntities(void)
{
	return @{
		@"AElig": @"??",
		@"Aacute": @"??",
		@"Acirc": @"??",
		@"Agrave": @"??",
		@"Alpha": @"??",
		@"Aring": @"??",
		@"Atilde": @"??",
		@"Auml": @"??",
		@"Beta": @"??",
		@"Ccedil": @"??",
		@"Chi": @"??",
		@"Dagger": @"???",
		@"Delta": @"??",
		@"ETH": @"??",
		@"Eacute": @"??",
		@"Ecirc": @"??",
		@"Egrave": @"??",
		@"Epsilon": @"??",
		@"Eta": @"??",
		@"Euml": @"??",
		@"Gamma": @"??",
		@"Iacute": @"??",
		@"Icirc": @"??",
		@"Igrave": @"??",
		@"Iota": @"??",
		@"Iuml": @"??",
		@"Kappa": @"??",
		@"Lambda": @"??",
		@"Mu": @"??",
		@"Ntilde": @"??",
		@"Nu": @"??",
		@"OElig": @"??",
		@"Oacute": @"??",
		@"Ocirc": @"??",
		@"Ograve": @"??",
		@"Omega": @"??",
		@"Omicron": @"??",
		@"Oslash": @"??",
		@"Otilde": @"??",
		@"Ouml": @"??",
		@"Phi": @"??",
		@"Pi": @"??",
		@"Prime": @"???",
		@"Psi": @"??",
		@"Rho": @"??",
		@"Scaron": @"??",
		@"Sigma": @"??",
		@"THORN": @"??",
		@"Tau": @"??",
		@"Theta": @"??",
		@"Uacute": @"??",
		@"Ucirc": @"??",
		@"Ugrave": @"??",
		@"Upsilon": @"??",
		@"Uuml": @"??",
		@"Xi": @"??",
		@"Yacute": @"??",
		@"Yuml": @"??",
		@"Zeta": @"??",
		@"aacute": @"??",
		@"acirc": @"??",
		@"acute": @"??",
		@"aelig": @"??",
		@"agrave": @"??",
		@"alefsym": @"???",
		@"alpha": @"??",
		@"amp": @"&",
		@"and": @"???",
		@"ang": @"???",
		@"apos": @"'",
		@"aring": @"??",
		@"asymp": @"???",
		@"atilde": @"??",
		@"auml": @"??",
		@"bdquo": @"???",
		@"beta": @"??",
		@"brvbar": @"??",
		@"bull": @"???",
		@"cap": @"???",
		@"ccedil": @"??",
		@"cedil": @"??",
		@"cent": @"??",
		@"chi": @"??",
		@"circ": @"??",
		@"clubs": @"???",
		@"cong": @"???",
		@"copy": @"??",
		@"crarr": @"???",
		@"cup": @"???",
		@"curren": @"??",
		@"dArr": @"???",
		@"dagger": @"???",
		@"darr": @"???",
		@"deg": @"??",
		@"delta": @"??",
		@"diams": @"???",
		@"divide": @"??",
		@"eacute": @"??",
		@"ecirc": @"??",
		@"egrave": @"??",
		@"empty": @"???",
		@"emsp": @"???",
		@"ensp": @"???",
		@"epsilon": @"??",
		@"equiv": @"???",
		@"eta": @"??",
		@"eth": @"??",
		@"euml": @"??",
		@"euro": @"???",
		@"exist": @"???",
		@"fnof": @"??",
		@"forall": @"???",
		@"frac12": @"??",
		@"frac14": @"??",
		@"frac34": @"??",
		@"frasl": @"???",
		@"gamma": @"??",
		@"ge": @"???",
		@"gt": @">",
		@"hArr": @"???",
		@"harr": @"???",
		@"hearts": @"???",
		@"hellip": @"???",
		@"iacute": @"??",
		@"icirc": @"??",
		@"iexcl": @"??",
		@"igrave": @"??",
		@"image": @"???",
		@"infin": @"???",
		@"int": @"???",
		@"iota": @"??",
		@"iquest": @"??",
		@"isin": @"???",
		@"iuml": @"??",
		@"kappa": @"??",
		@"lArr": @"???",
		@"lambda": @"??",
		@"lang": @"???",
		@"laquo": @"??",
		@"larr": @"???",
		@"lceil": @"???",
		@"ldquo": @"???",
		@"le": @"???",
		@"lfloor": @"???",
		@"lowast": @"???",
		@"loz": @"???",
		@"lrm": @"\xE2\x80\x8E",
		@"lsaquo": @"???",
		@"lsquo": @"???",
		@"lt": @"<",
		@"macr": @"??",
		@"mdash": @"???",
		@"micro": @"??",
		@"middot": @"??",
		@"minus": @"???",
		@"mu": @"??",
		@"nabla": @"???",
		@"nbsp": @"??",
		@"ndash": @"???",
		@"ne": @"???",
		@"ni": @"???",
		@"not": @"??",
		@"notin": @"???",
		@"nsub": @"???",
		@"ntilde": @"??",
		@"nu": @"??",
		@"oacute": @"??",
		@"ocirc": @"??",
		@"oelig": @"??",
		@"ograve": @"??",
		@"oline": @"???",
		@"omega": @"??",
		@"omicron": @"??",
		@"oplus": @"???",
		@"or": @"???",
		@"ordf": @"??",
		@"ordm": @"??",
		@"oslash": @"??",
		@"otilde": @"??",
		@"otimes": @"???",
		@"ouml": @"??",
		@"para": @"??",
		@"part": @"???",
		@"permil": @"???",
		@"perp": @"???",
		@"phi": @"??",
		@"pi": @"??",
		@"piv": @"??",
		@"plusmn": @"??",
		@"pound": @"??",
		@"prime": @"???",	// prime = minutes = fee
		@"prod": @"???",
		@"prop": @"???",
		@"psi": @"??",
		@"quot": @"???",
		@"rArr": @"???",
		@"radic": @"???",
		@"rang": @"???",
		@"raquo": @"??",
		@"rarr": @"???",
		@"rceil": @"???",
		@"rdquo": @"???",
		@"real": @"???",
		@"reg": @"??",
		@"rfloor": @"???",
		@"rho": @"??",
		@"rlm": @"\xE2\x80\x8F",
		@"rsaquo": @"???",
		@"rsquo": @"???",
		@"sbquo": @"???",
		@"scaron": @"??",
		@"sdot": @"???",
		@"sect": @"??",
		@"shy": @"\xC2\xAD",
		@"sigma": @"??",
		@"sigmaf": @"??",
		@"sim": @"???",
		@"spades": @"???",
		@"sub": @"???",
		@"sube": @"???",
		@"sum": @"???",
		@"sup": @"???",
		@"sup1": @"??",
		@"sup2": @"??",
		@"sup3": @"??",
		@"supe": @"???",
		@"szlig": @"??",
		@"tau": @"??",
		@"there4": @"???",
		@"theta": @"??",
		@"thetasym": @"??",
		@"thinsp": @"???",
		@"thorn": @"??",
		@"tilde": @"??",
		@"times": @"??",
		@"trade": @"???",
		@"uArr": @"???",
		@"uacute": @"??",
		@"uarr": @"???",
		@"ucirc": @"??",
		@"ugrave": @"??",
		@"uml": @"??",
		@"upsih": @"??",
		@"upsilon": @"??",
		@"uuml": @"??",
		@"weierp": @"???",
		@"xi": @"??",
		@"yacute": @"??",
		@"yen": @"??",
		@"yuml": @"??",
		@"zeta": @"??",
		@"zwj": @"\xE2\x80\x8D",
		@"zwnj": @"\xE2\x80\x8C"};
}
