/*
 * The MIT License
 * Copyright (c) 2015 Recurly, Inc.

 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <UIKit/UIKit.h>
#import "FormFieldViewCell.h"


@interface CardPaymentViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *tokenLabel;
@property (weak, nonatomic) IBOutlet FormFieldViewCell *firstNameField;
@property (weak, nonatomic) IBOutlet FormFieldViewCell *lastNameField;
@property (weak, nonatomic) IBOutlet FormFieldViewCell *countryField;
@property (weak, nonatomic) IBOutlet FormFieldViewCell *numberField;
@property (weak, nonatomic) IBOutlet FormFieldViewCell *cvvField;
@property (weak, nonatomic) IBOutlet FormFieldViewCell *monthField;
@property (weak, nonatomic) IBOutlet FormFieldViewCell *yearField;

+ (instancetype)createFromNib;

@end
