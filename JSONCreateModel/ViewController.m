//
//  ViewController.m
//  S
//
//  Created by caiming on 15/8/24.
//  Copyright (c) 2015年 caiming. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+JSONSerialization.h"

@interface ViewController ()<NSTextViewDelegate>

@property(nonatomic, strong)NSString *path;
@property (weak) IBOutlet NSButton *chooseBtn;
@property (unsafe_unretained) IBOutlet NSTextView *inputTV;
@property (weak) IBOutlet NSTextField *classNameTF;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    NSDictionary *d = @{@"userId":@1000,@"userName":@"姓名",@"userInfo":@{@"sex":@1,@"avatar":[NSNull null]}};
    
    if ([NSJSONSerialization isValidJSONObject:d])
    {
        
    }
    NSString *s = [NSObject jsonStringFromData:d];
    NSLog(@"%@",s);
    
//    [self generateClass:@"UserModel" forDic:d];
    _inputTV.delegate = self;

    [_chooseBtn setTitle:@"无效的json"];
    _chooseBtn.enabled = NO;
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
- (IBAction)onChooseBtnAction:(id)sender {
    
    [self openFileDialog];
}

-(void)openFileDialog
{
    
    // Create the File Open Dialog class.
//    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
//    
//    // Enable the selection of files in the dialog.
//    [openDlg setCanChooseFiles:NO];
//    
//    // Enable the selection of directories in the dialog.
//    [openDlg setCanChooseDirectories:YES];
//    
//    if ([openDlg runModal] == NSModalResponseOK) {
//        
//        NSArray* files = [openDlg URLs];
//        
//        // Loop through all the files and process them.
//        for( int i = 0; i < [files count]; i++ )
//        {
//            NSString* fileName = [files objectAtIndex:i];
//            NSLog(@"%@",fileName);
//            _path = fileName;
//            // Do something with the filename.
//            id obj = [NSObject dataFormJsonString:_inputTV.string];
//            [self generateClass:@"userModel" forDic:obj];
//        }
//
//    }
    if (_classNameTF.stringValue.length<1) {
        
        NSAlert *alert = [[NSAlert alloc]init];
        alert.informativeText = @"请填写基类名称";
        alert.messageText = @"请填写基类名称";
        [alert addButtonWithTitle:@"知道了"];

        [alert setAlertStyle:NSCriticalAlertStyle];
        
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        return;
    }
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseDirectories = YES;
    panel.canChooseFiles = NO;
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        
        if(result == 0) return ;
        
        _path = [panel.URL path];
        id obj = [NSObject dataFormJsonString:_inputTV.string];
        [self generateClass:_classNameTF.stringValue forDic:obj];
        
    }];
    



}



-(void)generateClass:(NSString *)name forDic:(NSDictionary *)json
{
    
    //准备模板
    NSMutableString *templateH =[[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"json" ofType:@"zx1"]
                                                                       encoding:NSUTF8StringEncoding
                                                                          error:nil];
    NSMutableString *templateM =[[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"json" ofType:@"zx2"]
                                                                       encoding:NSUTF8StringEncoding
                                                                          error:nil];
    
    //.h
    //name
    //property
    
    NSString *preName = @"";
    
    NSMutableString *proterty = [NSMutableString string];
    NSMutableString *import = [NSMutableString string];
    
    for(NSString *key in [json allKeys])
    {
        NSString *acKey = [self uppercaseFirstChar:key];
        acKey = [NSString stringWithFormat:@"m%@",acKey];
        
        JsonValueType type = [self type:[json objectForKey:key]];
        switch (type) {
            case kString:
            case kNumber:
                [proterty appendFormat:@"@property (nonatomic,strong) %@ *%@%@;\n",[self typeName:type],preName,acKey];
                break;
            case kArray:
            {
                if([self isDataArray:[json objectForKey:key]])
                {
                    [proterty appendFormat:@"@property (nonatomic,strong) NSMutableArray *%@%@;\n",preName,acKey];
                    
                    [import appendFormat:@"#import \"%@Entity.h\"",[self uppercaseFirstChar:acKey]];
                    [self generateClass:[NSString stringWithFormat:@"%@Entity",[self uppercaseFirstChar:acKey]] forDic:[[json objectForKey:key]objectAtIndex:0]];
                }
            }
                break;
            case kDictionary:
                [proterty appendFormat:@"@property (nonatomic,strong) %@Entity *%@%@;\n",[self uppercaseFirstChar:acKey],preName,acKey];
                
                [import appendFormat:@"#import \"%@Entity.h\"",[self uppercaseFirstChar:acKey]];
                [self generateClass:[NSString stringWithFormat:@"%@Entity",[self uppercaseFirstChar:acKey]] forDic:[json objectForKey:key]];
                
                break;
            case kBool:
                
                [proterty appendFormat:@"@property (nonatomic,assign) %@ %@%@;\n",[self typeName:type],preName,acKey];
                
                break;
            case kId:
                [proterty appendFormat:@"@property (nonatomic,strong) %@ %@%@;\n",[self typeName:type],preName,acKey];

            default:
                break;
        }
    }
    
    [templateH replaceOccurrencesOfString:@"#name#"
                               withString:name
                                  options:NSCaseInsensitiveSearch
                                    range:NSMakeRange(0, templateH.length)];
    [templateH replaceOccurrencesOfString:@"#import#"
                               withString:import
                                  options:NSCaseInsensitiveSearch
                                    range:NSMakeRange(0, templateH.length)];
    [templateH replaceOccurrencesOfString:@"#property#"
                               withString:proterty
                                  options:NSCaseInsensitiveSearch
                                    range:NSMakeRange(0, templateH.length)];
    
    //.m
    //name
    [templateM replaceOccurrencesOfString:@"#name#"
                               withString:name
                                  options:NSCaseInsensitiveSearch
                                    range:NSMakeRange(0, templateM.length)];
    
    NSMutableString *config = [NSMutableString string];
//    NSMutableString *description = [NSMutableString string];
    NSMutableString *constKey = [NSMutableString string];
    NSMutableString *dictionaryRepresentation = [NSMutableString string];
    NSDictionary *list =  @{
                            @"config":config,
//                            @"description":description,
                            @"const":constKey,
                            @"dictionaryRepresentation":dictionaryRepresentation
                            };
    
    
    for(NSString *key in [json allKeys])
    {
        NSString *acKey = [self uppercaseFirstChar:key];
        acKey = [NSString stringWithFormat:@"m%@",acKey];
        
        JsonValueType type = [self type:[json objectForKey:key]];
        [constKey appendFormat:@"NSString *const k%@%@ = @\"%@\";\n",name,[self uppercaseFirstChar:acKey],key];
        
        switch (type) {
            case kString:
            case kNumber:
                [config appendFormat:@"self.%@%@  = [self objectOrNilForKey:k%@%@ fromDictionary:json];\n ",preName,acKey,name,[self uppercaseFirstChar:acKey]];

                [dictionaryRepresentation appendFormat:@"[mutableDict setValue:self.%@%@ forKey:k%@%@];\n",preName,acKey,name,[self uppercaseFirstChar:acKey]];
                
                break;
            case kArray:
            {
                if([self isDataArray:[json objectForKey:key]])
                {
                    [config appendFormat:@"self.%@%@ = [NSMutableArray array];\n",preName,acKey];
                    
                    [config appendFormat:@"for(NSDictionary *item in [json objectForKey:@\"%@\"])\n",key];
                    [config appendString:@"{\n"];
                    
                    [config appendFormat:@"[self.%@%@ addObject:[%@Entity modelObjectWithDictionary:item]];\n",preName,acKey,[self uppercaseFirstChar:acKey]];
                    
                    [config appendString:@"}\n"];
                    
//                    [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@%@ : %%@\\n\",self.%@%@];\n",preName,key,preName,key];
                }
            }
                break;
            case kDictionary:
                [config appendFormat:@"self.%@%@  = [%@Entity modelObjectWithDictionary:[json objectForKey:@\"%@\"]];\n ",preName,acKey,[self uppercaseFirstChar:acKey],key];
                
//                [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@%@ : %%@\\n\",self.%@%@];\n",preName,key,preName,key];
                
                break;
            case kBool:
//                [config appendFormat:@"self.%@%@ = [[json objectForKey:@\"%@\"]boolValue];\n ",preName.stringValue,key,key];
//                [encode appendFormat:@"[aCoder encodeBool:self.%@%@ forKey:@\"zx_%@\"];\n",preName.stringValue,key,key];
//                [decode appendFormat:@"self.%@%@ = [aDecoder decodeBoolForKey:@\"zx_%@\"];\n",preName.stringValue,key,key];
//                [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@%@ : %%@\\n\",self.%@%@?@\"yes\":@\"no\"];\n",preName.stringValue,key,preName.stringValue,key];
                break;
            default:
                break;
        }
    }
    
    //修改模板
    for(NSString *key in [list allKeys])
    {
        [templateM replaceOccurrencesOfString:[NSString stringWithFormat:@"#%@#",key]
                                   withString:[list objectForKey:key]
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateM.length)];
    }
    
//    
//    NSOpenPanel *panel = [NSOpenPanel openPanel];
//    panel.canChooseDirectories = YES;
//    panel.canChooseFiles = NO;
//    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
//        
//        if(result == 0) return ;
//        
//        
//    }];
    
    
    //写文件
    [templateH writeToFile:[NSString stringWithFormat:@"%@/%@.h",_path,name]
                atomically:NO
                  encoding:NSUTF8StringEncoding
                     error:nil];
    [templateM writeToFile:[NSString stringWithFormat:@"%@/%@.m",_path,name]
                atomically:NO
                  encoding:NSUTF8StringEncoding
                     error:nil];
    
}
-(JsonValueType)type:(id)obj
{
//    if([[obj className] isEqualToString:@"__NSCFString"] || [[obj className] isEqualToString:@"__NSCFConstantString"]) return kString;
//    
//    else if([[obj className] isEqualToString:@"__NSCFNumber"]) return kNumber;
//    else if([[obj className] isEqualToString:@"__NSCFBoolean"])return kNumber;
//    else if([[obj className] isEqualToString:@"__NSCFDictionary"])return kDictionary;
//    else if([[obj className] isEqualToString:@"__NSArrayI"])return kArray;
    
    if ([obj isKindOfClass:[NSString class]]) {
        
        return kString;
    }else if ([obj isKindOfClass:[NSNumber class]])
    {
        return kNumber;
    }
    else if ([obj isKindOfClass:[NSDictionary class]])
    {
        return kDictionary;
        
    }else if ([obj isKindOfClass:[NSArray class]])
    {
        return kArray;
    }
    
    
    
    return kId;
}


-(NSString *)typeName:(JsonValueType)type
{
    switch (type) {
        case kString:
            return @"NSString";
            break;
        case kNumber:
            return @"NSNumber";
            break;
        case kBool:
            return @"BOOL";
            break;
        case kArray:
        case kDictionary:
            return @"";
            break;
        case kId:
            return @"id";
            break;
        default:
            break;
    }
}

//表示该数组内有且只有字典 并且 结构一致。
-(BOOL)isDataArray:(NSArray *)theArray
{
    if(theArray.count <=0 ) return NO;
    for(id item in theArray)
    {
        if([self type:item] != kDictionary)
        {
            return NO;
        }
    }
    
    NSMutableSet *keys = [NSMutableSet set];
    for(NSString *key in [[theArray objectAtIndex:0] allKeys])
    {
        [keys addObject:key];
    }
    
    
    for(id item in theArray)
    {
        NSMutableSet *newKeys = [NSMutableSet set];
        for(NSString *key in [item allKeys])
        {
            [newKeys addObject:key];
        }
        
        if([keys isEqualToSet:newKeys] == NO)
        {
            return NO;
        }
    }
    return YES;
}
-(NSString *)uppercaseFirstChar:(NSString *)str
{
    return [NSString stringWithFormat:@"%@%@",[[str substringToIndex:1] uppercaseString],[str substringWithRange:NSMakeRange(1, str.length-1)]];
}

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
    NSLog(@"%@",textView.string);

    NSString *text = [textView.string stringByReplacingCharactersInRange:affectedCharRange withString:replacementString];
    NSLog(@"%@",text);
    id obj = [NSObject dataFormJsonString:text];
    
    if ([NSJSONSerialization isValidJSONObject:obj]) {
        
        [_chooseBtn setTitle:@"生成Model"];
        _chooseBtn.enabled = YES;
        
    }else
    {
        [_chooseBtn setTitle:@"无效的Json"];
        _chooseBtn.enabled = NO;
    }
    return YES;
}
@end
