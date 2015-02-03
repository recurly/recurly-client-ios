//
//  FormFieldViewCell.h
//  RecurlySDK
//
//  Created by Manuel Martinez-Almeida on 04/12/14.
//  Copyright (c) 2014 Recurly Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef BOOL (^ValueChanged)(NSString *value);
typedef void (^EditingEnded)(NSString *value);

IB_DESIGNABLE
@interface FormFieldViewCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *fieldNameLabel;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, strong) ValueChanged valueChanged;
@property (nonatomic, strong) EditingEnded editingEnded;
@property (nonatomic, assign) char state;
@property (nonatomic, weak) UITextField *nextTextField;


- (NSString *)textValue;
- (void)setTextValue:(NSString *)text;
- (void)setFieldName:(NSString *)fieldName;

@end
