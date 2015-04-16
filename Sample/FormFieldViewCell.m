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

#import "FormFieldViewCell.h"


@implementation FormFieldViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSString *className = NSStringFromClass([self class]);
        UIView *view = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
        [view setFrame:[self frame]];
        self.tag = view.tag;
        [self addSubview:view];
        return self;
    }
    return nil;
}

- (NSString *)textValue
{
    return [_textField text];
}

- (void)setTextValue:(NSString *)text
{
    [_textField setText:text];
}

- (void)setFieldName:(NSString *)fieldName
{
    [_textField setPlaceholder:fieldName];
    [_fieldNameLabel setText:[fieldName lowercaseString]];
}


#pragma mark - TextField delegate

- (IBAction)valueChanged:(id)sender
{
    BOOL shouldHide = [[_textField text] length] == 0;
    if(shouldHide) {
        [self hideFieldName];
    }else{
        [self showFieldName];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(_nextTextField)
        [_nextTextField becomeFirstResponder];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(_editingEnded)
        _editingEnded(textField.text);
    else{
        NSUInteger length = [textField.text length];
        if(length == 0) {
            [self setValueNormal];
        }else if(length < 2) {
            [self setValueIsInvalid];
        }else {
            [self setValueIsValid];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    NSString *newValue = [textField.text stringByReplacingCharactersInRange:range withString:string];
    BOOL shouldChange = YES;
    if(_valueChanged) {
        shouldChange = _valueChanged(newValue);
        if(!shouldChange) {
            [self valueChanged:nil];
        }
    }
    [self setValueNormal];
    return shouldChange;
}


- (void)setState:(char)aState
{
    switch (aState) {
        case 0:
            [self setValueNormal];
            break;
        case 1:
            [self setValueIsValid];
            break;
        case 2:
            [self setValueIsInvalid];
            break;
        default:
            return;
    }
    _state = aState;
}

#pragma mark - Animation

- (void)hideFieldName
{
    if(![_fieldNameLabel isHidden]) {
        [UIView animateWithDuration:0.2 animations:^{
            [_fieldNameLabel setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [_fieldNameLabel setHidden:YES];
        }];
    }
}

- (void)showFieldName
{
    if([_fieldNameLabel isHidden]) {
        [_fieldNameLabel setHidden:NO];
        [UIView animateWithDuration:0.2 animations:^{
            [_fieldNameLabel setAlpha:1.0f];
        }];
    }
}


- (void)setValueNormal
{
    [_fieldNameLabel setTextColor:[UIColor lightGrayColor]];
}


- (void)setValueIsValid
{
    UIColor *color = [UIColor colorWithRed:150.0f/255 green:1.0f blue:150.0f/255 alpha:1.0f];
    [self setBackgroundColor:color];
    [self setValueNormal];
    [UIView animateWithDuration:0.4 animations:^{
        [self setBackgroundColor:[UIColor whiteColor]];
    }];
}

- (void)setValueIsInvalid
{
    UIColor *color = [UIColor colorWithRed:1.0f green:125.0f/255 blue:137.0f/255 alpha:1.0f];
    [self setBackgroundColor:color];
    [_fieldNameLabel setTextColor:color];
    [UIView animateWithDuration:0.5 animations:^{
        [self setBackgroundColor:[UIColor whiteColor]];
    }];
}

@end

