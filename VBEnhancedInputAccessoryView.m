//
//  VBEnhancedInputAccessoryView.m
//  VBEnhancedInputAccessoryView CLASS
//
//  Created by Vitalii Budnik on 11/22/14.
//  Copyright (c) 2014 iNekrich. All rights reserved.
//

#import "VBEnhancedInputAccessoryView.h"

@interface VBEnhancedInputAccessoryView ()

@property (strong, nonatomic) UISegmentedControl *navigationButtons;
@property (strong, nonatomic) UIBarButtonItem *navigationButtonsItem;
@property (strong, nonatomic) UIBarButtonItem *flexibleSpace;
@property (strong, nonatomic) UIBarButtonItem *doneButton;

@property (weak, nonatomic) UIView *objectSuperview;

@property (strong, nonatomic) NSArray *arrayOfInputViews;
@property (nonatomic) NSUInteger indexOfCurrentObjectInArray;

@property (nonatomic) NSUInteger inputViewsCount;
@property (nonatomic) NSInteger minTag;
@property (nonatomic) NSInteger maxTag;

@property (strong, nonatomic) NSArray *items;

@end

@implementation VBEnhancedInputAccessoryView

- (instancetype)init {
	self = [super init];
	if (self) {
		
		[self sizeToFit];
		
		self.inputViewsCount = NSNotFound;
		
		self.handlePreviousNextButtons = YES;
		self.handleDoneButton = YES;
		
		self.navigationButtonsOnTheLeft = YES;
		
		UISwipeGestureRecognizer *swipeLeftRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
		[swipeLeftRight setDirection:(UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft )];
		[self addGestureRecognizer:swipeLeftRight];
	}
	return self;
}

#pragma mark - properties setters & getters + lazy initializations

- (UIBarButtonItem *)flexibleSpace {
	if (!_flexibleSpace) {
		_flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	}
	return _flexibleSpace;
}

- (UISegmentedControl *)navigationButtons {
	if (!_navigationButtons) {
		_navigationButtons = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Previous", @"Next", nil]];
		_navigationButtons.momentary = YES; // do not preserve button's state
		[_navigationButtons addTarget:self action:@selector(nextPreviousHandlerDidChange:) forControlEvents:UIControlEventValueChanged];
	}
	return _navigationButtons;
}

- (UIBarButtonItem *)navigationButtonsItem {
	if (!_navigationButtonsItem) {
		_navigationButtonsItem = [[UIBarButtonItem alloc] initWithCustomView:self.navigationButtons];
	}
	return _navigationButtonsItem;
}

- (UIBarButtonItem *)doneButton {
	if (!_doneButton) {
		_doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																	target:self
																	action:@selector(doneDidClick:)];
	}
	return _doneButton;
}

- (void)setNavigationButtonsOnTheLeft:(BOOL)navigationButtonsOnTheLeft {
	_navigationButtonsOnTheLeft = navigationButtonsOnTheLeft;
	
	UIBarButtonItem *firstItem = self.navigationButtonsOnTheLeft ? self.navigationButtonsItem : self.doneButton;
	UIBarButtonItem *lastItem = self.navigationButtonsOnTheLeft ? self.doneButton : self.navigationButtonsItem;
	
	self.items = @[firstItem, self.flexibleSpace, lastItem];
}

- (void)setObjectSuperview:(UIView *)objectSuperview {
	if (_objectSuperview != objectSuperview) {
		_objectSuperview = objectSuperview;
		[self reidentifyInputViews];
	}
}

- (void)setArrayOfInputViews:(NSArray *)arrayOfInputViews {
	_arrayOfInputViews = arrayOfInputViews;
	self.indexOfCurrentObjectInArray = [arrayOfInputViews indexOfObject:self.object];
}

#pragma mark - Object setters

- (void)setObject:(UIView <UITextInputTraits> *)object {
	[self setObject:object andReidentifyInputViews:NO];
}

- (void)setObject:(UIView <UITextInputTraits> *)object andReidentifyInputViews:(BOOL)reidentifyInputViews {
	[self setObject:object locatedInSuperview:nil andReidentifyInputViews:reidentifyInputViews];
}

- (void)setObject:(UIView <UITextInputTraits> *)object locatedInSuperview:(UIView *)objectSuperview {
	[self setObject:object locatedInSuperview:objectSuperview andReidentifyInputViews:NO];
}

- (void)setObject:(UIView <UITextInputTraits> *)object locatedInSuperview:(UIView *)objectSuperview andReidentifyInputViews:(BOOL)reidentifyInputViews {
	
	UIView *newObjectSuperview = objectSuperview;
	if (object) {
		if (!newObjectSuperview) {
			newObjectSuperview = object.superview;
		}
	} else {
		newObjectSuperview = nil;
	}
	
	if (newObjectSuperview != self.objectSuperview) {
		self.objectSuperview = newObjectSuperview;
	} else if (reidentifyInputViews) {
		[self reidentifyInputViews];
	}
	
	if (_object != object) {
		_object = object;
	}
	
	if (self.object) {
		if (!self.navigateByTags) {
			self.indexOfCurrentObjectInArray = [self.arrayOfInputViews indexOfObject:self.object];
		}
		[self prepareForObject:self.object withPreviousEnabled:[self isTherePreviousTextInput] nextEnabled:[self isThereNextTextInput] doneEnabled:YES];
	} else if (!self.navigateByTags) {
		self.indexOfCurrentObjectInArray = NSNotFound;
		[self prepareForObject:self.object withPreviousEnabled:NO nextEnabled:NO doneEnabled:NO];
	}
}

#pragma mark - Configurating self for navigation

- (void)reidentifyInputViews {
	if (self.navigateByTags) {
		self.maxTag = NSIntegerMin;
		self.minTag = NSIntegerMax;
		self.inputViewsCount = [self countInputViews:self.objectSuperview];
	} else {
		self.arrayOfInputViews = [self arrayOfInputViews:self.objectSuperview];
	}
}

- (void)reidentifyInputViewsAndUpdateNavigationAviability {
	
	[self reidentifyInputViews];
	
	[self prepareForObject:self.object withPreviousEnabled:[self isTherePreviousTextInput] nextEnabled:[self isThereNextTextInput] doneEnabled:YES];
	
}

- (BOOL)canManageView:(UIView *)view {
	return [view conformsToProtocol:@protocol(UITextInputTraits)] && view.tag != 0 && view.canBecomeFirstResponder && !view.hidden;
}

- (NSUInteger)countInputViews:(UIView *)aView {
	if (!aView) {
		return 0;
	}
	NSUInteger inputViewsCount = 0;
	for (UIView *view in aView.subviews) {
		if ([self canManageView:view]) {
			++inputViewsCount;
			self.maxTag = MAX(self.maxTag, view.tag);
			self.minTag = MIN(self.minTag, view.tag);
		} else if ([view.subviews count] > 0) {
			inputViewsCount += [self countInputViews:view];
		}
	}
	return inputViewsCount;
}

- (NSArray *)arrayOfInputViews:(UIView *)aView {
	if (!aView) {
		return [NSArray new];
	}
	
	NSMutableArray *arrayOfInputViews = [NSMutableArray new];
	for (UIView *view in aView.subviews) {
		if ([self canManageView:view]) {
			[arrayOfInputViews addObject:view];
		} else if ([view.subviews count] > 0) {
			[arrayOfInputViews addObjectsFromArray:[self arrayOfInputViews:view]];
		}
	}
	[arrayOfInputViews sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES]]];
	return [NSArray arrayWithArray:arrayOfInputViews];
}

- (void)prepareForObject:(UIView <UITextInputTraits> *)object withPreviousEnabled:(BOOL)prevEnabled nextEnabled:(BOOL)nextEnabled doneEnabled:(BOOL)doneEnabled {
	
	[self.navigationButtons setEnabled:prevEnabled forSegmentAtIndex:0];
	[self.navigationButtons setEnabled:nextEnabled forSegmentAtIndex:1];
	[self.doneButton setEnabled:doneEnabled];
	
	if (!object) {
		return;
	}
	
	if (object.returnKeyType == UIReturnKeyDefault) {
		UIReturnKeyType returnKeyType = UIReturnKeyDefault;
		if (nextEnabled) {
			returnKeyType = UIReturnKeyNext;
		} else {
			returnKeyType = UIReturnKeyDone;
		}
		object.returnKeyType = returnKeyType;
	}
	
	UIBarStyle barStyle = UIBarStyleDefault;
	if (object.keyboardAppearance != UIKeyboardAppearanceDefault && object.keyboardAppearance == UIKeyboardAppearanceDark) {
		if (self.translucent) {
			barStyle = UIBarStyleBlackTranslucent;
		} else {
			barStyle = UIBarStyleBlackOpaque;
		}
	}
	if (self.barStyle != barStyle) {
		self.barStyle = barStyle;
	}
	
}

#pragma mark - Navigation handling

- (void)nextPreviousHandlerDidChange:(UISegmentedControl *)sender
{
	switch ([sender selectedSegmentIndex])
	{
		case 0:
			[self enhancedKeyboardPreviousDidTouchDownInObject:self.object];
			break;
		case 1:
			[self enhancedKeyboardNextDidTouchDownInObject:self.object];
			break;
		default:
			break;
	}
}

- (void)enhancedKeyboardPreviousDidTouchDownInObject:(UIView <UITextInputTraits> *)object {
	if (self.objectSuperview && self.handlePreviousNextButtons) {
		UIResponder *previousResponder = [self previousTextInput];
		if (previousResponder) {
			[previousResponder becomeFirstResponder];
		}
	}
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(enhancedKeyboardPreviousDidTouchDownForObject:withPreviousObject:)]) {
		[self.delegate enhancedKeyboardPreviousDidTouchDownForObject:object withPreviousObject:[self previousTextInput]];
	}
}

- (void)enhancedKeyboardNextDidTouchDownInObject:(UIView <UITextInputTraits> *)object {
	if (self.objectSuperview && self.handlePreviousNextButtons) {
		UIResponder *nextResponder = [self nextTextInput];
		if (nextResponder) {
			[nextResponder becomeFirstResponder];
		}
	}
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(enhancedKeyboardNextDidTouchDownForObject:withNextObject:)]) {
		[self.delegate enhancedKeyboardNextDidTouchDownForObject:object withNextObject:[self nextTextInput]];
	}
}

- (void)doneDidClick:(UIBarButtonItem *)sender
{
	[self enhancedKeyboardDoneDidTouchDownInObject:self.object];
}

- (void)enhancedKeyboardDoneDidTouchDownInObject:(UIView <UITextInputTraits> *)object {
	if (self.handleDoneButton) {
		if (self.object) {
			if ([self.object isFirstResponder]) {
				[self.object resignFirstResponder];
			}
		}
		
		if (![self isThereNextTextInput]) {
			if (self.delegate
				&& [self.delegate conformsToProtocol:@protocol(UITextFieldDelegate)]
				&& [self.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
				[(UIView <UITextFieldDelegate> *)self.delegate textFieldShouldReturn:(UITextField *)object];
			}
		}
	}
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(enhancedKeyboardDoneDidTouchDownInObject:)]) {
		[self.delegate enhancedKeyboardDoneDidTouchDownForObject:object];
	}
}

#pragma mark - get Previous/Next objects

- (BOOL)textInputViewWithTag:(NSInteger)tag {
	UIView *textInputView = [self.objectSuperview viewWithTag:tag];
	if ([self canManageView:textInputView]) {
		return YES;
	} else {
		return NO;
	}
}

#pragma mark Previous

- (BOOL)isTherePreviousTextInput {
	if (self.navigateByTags) {
		return [self isTherePreviousTextInputForTag:self.object.tag];
	} else {
		return [self isTherePreviousTextInputInArray];
	}
}

- (BOOL)isTherePreviousTextInputInArray {
	return self.indexOfCurrentObjectInArray > 0 && self.indexOfCurrentObjectInArray <= ([self.arrayOfInputViews count] - 1);
}

- (BOOL)isTherePreviousTextInputForTag:(NSInteger)tag {
	if (tag == self.minTag) {
		return NO;
	}
	NSInteger previousTag = tag - 1;
	BOOL result;
	if (![self textInputViewWithTag:previousTag]) {
		result = [self isTherePreviousTextInputForTag:previousTag];
	} else {
		result = YES;
	}
	return result;
}

- (UIView <UITextInputTraits> *)previousTextInput {
	if (self.navigateByTags) {
		return [self previousTextInputForTag:self.object.tag];
	} else {
		return [self previousTextInputInArray];
	}	
}

- (UIView <UITextInputTraits> *)previousTextInputInArray {
	if ([self isTherePreviousTextInputInArray]) {
		return [self.arrayOfInputViews objectAtIndex:self.indexOfCurrentObjectInArray - 1];
	} else {
		return nil;
	}
}

- (UIView <UITextInputTraits> *)previousTextInputForTag:(NSInteger)tag {
	if (tag == self.minTag) {
		return nil;
	}
	NSInteger previousTag = tag - 1;
	if ([self textInputViewWithTag:previousTag]) {
		return (UIView <UITextInputTraits> *)[self.objectSuperview viewWithTag:previousTag];
	} else {
		return [self previousTextInputForTag:previousTag];
	}
}

#pragma mark Next

- (BOOL)isThereNextTextInput {
	if (self.navigateByTags) {
		return [self isThereNextTextInputForTag:self.object.tag];
	} else {
		return [self isThereNextTextInputInArray];
	}
}

- (BOOL)isThereNextTextInputInArray {
	return self.indexOfCurrentObjectInArray != NSNotFound && (self.indexOfCurrentObjectInArray < [self.arrayOfInputViews count] - 1);
}

- (BOOL)isThereNextTextInputForTag:(NSInteger)tag {
	if (tag == self.maxTag) {
		return NO;
	}
	NSInteger nextTag = tag + 1;
	BOOL result;
	if (![self textInputViewWithTag:nextTag]) {
		result = [self isThereNextTextInputForTag:nextTag];
	} else {
		result = YES;
	}
	return result;
}

- (UIView <UITextInputTraits> *)nextTextInput {
	if (self.navigateByTags) {
		return [self nextTextInputForTag:self.object.tag];
	} else {
		return [self nextTextInputInArray];
	}
}

- (UIView <UITextInputTraits> *)nextTextInputInArray {
	if ([self isThereNextTextInputInArray]) {
		return [self.arrayOfInputViews objectAtIndex:self.indexOfCurrentObjectInArray + 1];
	} else {
		return nil;
	}
}

- (UIView <UITextInputTraits> *)nextTextInputForTag:(NSInteger)tag {
	if (tag == self.maxTag) {
		return nil;
	}
	NSInteger nextTag = tag + 1;
	if (nextTag <= 0) {
		return nil;
	}
	if ([self textInputViewWithTag:nextTag]) {
		return (UIView <UITextInputTraits> *)[self.objectSuperview viewWithTag:nextTag];
	} else {
		return [self nextTextInputForTag:nextTag];
	}
}

#pragma mark - UISwipeGestureRecognizer handler

- (void)handleSwipe:(UISwipeGestureRecognizer *)recognizer {
	if (recognizer.direction == (UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft )) {
		self.navigationButtonsOnTheLeft = !self.navigationButtonsOnTheLeft;
	}
}

@end
