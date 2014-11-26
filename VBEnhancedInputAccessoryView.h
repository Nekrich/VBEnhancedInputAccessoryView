//
//  VBEnhancedInputAccessoryView.h
//  VBEnhancedInputAccessoryView CLASS
//
//  Created by Vitalii Budnik on 11/22/14.
//  Copyright (c) 2014 iNekrich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** 
 * The VBEnhancedInputAccessoryViewDelegate protocol defines the messages
 * sent to a VBEnhancedInputAccessoryView delegate as part of the sequence of navigating.
 * All of the methods of this protocol are optional.
 */
@protocol VBEnhancedInputAccessoryViewDelegate <UIToolbarDelegate>

@optional

/**
 * Tells the delegate that "Previous" button pressed in VBEnhancedInputAccessoryView
 * for the specified text input view.
 *
 * This method notifies the delegate that the user wants to edit previous text field.
 * You can use this method to update your delegate’s state information.
 * For example, you might use this method to update your model, or view and handle
 * navigation manually.
 *
 * Implementation of this method by the delegate is optional.
 * @param object (UIView <UITextInputTraits> *) Current text field (current first responder on UIView)
 * @param previousObject (UIView <UITextInputTraits> *) Previous text field in UIView.
 * nil, if there are no previous text fields. (current text field is first)
 */
- (void)enhancedKeyboardPreviousDidTouchDownForObject:(UIView <UITextInputTraits> *)object withPreviousObject:(UIView <UITextInputTraits> *)previousObject;

/**
 * Tells the delegate that "Next" button pressed in VBEnhancedInputAccessoryView
 * for the specified text input view.
 *
 * This method notifies the delegate that the user wants to edit next text field.
 * You can use this method to update your delegate’s state information.
 * For example, you might use this method to update your model, or view and handle
 * navigation manually.
 *
 * Implementation of this method by the delegate is optional.
 * @param object (UIView <UITextInputTraits> *) Current text field (current first responder on UIView)
 * @param nextObject (UIView <UITextInputTraits> *) Next text field in UIView.
 * nil, if there are no next text fields. (current text field is last)
 */
- (void)enhancedKeyboardNextDidTouchDownForObject:(UIView <UITextInputTraits> *)object withNextObject:(UIView <UITextInputTraits> *)nextObject;

/**
 * Tells the delegate that "Done" button pressed in VBEnhancedInputAccessoryView
 * for the specified text input view.
 *
 * This method notifies the delegate that the user wants to end edit current text field.
 * You can use this method to update your delegate’s state information.
 * For example, you might use this method to update your model, or view and handle
 * navigation manually.
 *
 * Implementation of this method by the delegate is optional.
 * @param object (UIView <UITextInputTraits> *) Current text field (current first responder on UIView)
 */
- (void)enhancedKeyboardDoneDidTouchDownForObject:(UIView <UITextInputTraits> *)object;

@end

/** 
 * A VBEnhancedInputAccessoryView is a toolbar that displays "Next"/"Previous"/"Done" buttons
 * for simple use as input accessory view in input controllers
 *
 * Can handle navigation through input controllers on your view by itself
 */
@interface VBEnhancedInputAccessoryView : UIToolbar

/// The receiver’s delegate.
@property (nonatomic, weak) id <VBEnhancedInputAccessoryViewDelegate> delegate;

/*
 * Current object in view, that isFirstResponder, with active keyboard input view
 * with this input accessory
 */
@property (weak, nonatomic) UIView <UITextInputTraits> *object;

/**
 * Sets current objects, and reidentifying subviews for object.superview, that confirms
 * to (UIView <UITextInputTraits> *) and can became first responder and not hidden. Recomended to use, when you need
 * keyboard enchanced accessory view for new object, and changed accessability
 * for some (UIView <UITextInputTraits> *) components on object.superview
 *
 * Recomended to use, when you need keyboard input accessory view for new object, and changed
 * accessability (enabled, hidden) of other text inputs for some (UIView <UITextInputTraits> *)
 * components or added/deleted ones on object.superview
 *
 * @param object A new (UIView <UITextInputTraits> *) object
 * @param andReidentifyInputViews A Boolean, that indicates to reidentify or not other objects
 * (`YES` - reidentify, 'NO' - not)
 */
- (void)setObject:(UIView <UITextInputTraits> *)object andReidentifyInputViews:(BOOL)reidentifyInputViews;

/**
 * Sets current objects, and reidentifying subviews for objectSuperview parameter,
 * that confirms to (UIView <UITextInputTraits> *) and can became first responder and not hidden.
 *
 * Recomended to use, when you need keyboard input accessory view for new object, and changed
 * accessability (enabled, hidden) of other text inputs for some (UIView <UITextInputTraits> *)
 * components or added/deleted ones on current objectSuperview
 *
 * @param object A new (UIView <UITextInputTraits> *) object
 * @param andReidentifyInputViews A Boolean, that indicates to reidentify or not other objects
 * (`YES` - reidentify, 'NO' - not)
 */
- (void)setObject:(UIView <UITextInputTraits> *)object locatedInSuperview:(UIView *)objectSuperview;

/**
 * Sets current objects, and reidentifying subviews for objectSuperview parameter,
 * that confirms to (UIView <UITextInputTraits> *) and can became first responder and not hidden.
 *
 * Recomended to use, when you need keyboard input accessory view for new object, and changed
 * accessability (enabled, hidden) of other text inputs for some (UIView <UITextInputTraits> *)
 * components or added/deleted ones on objectSuperview parameter
 *
 * @param object A new (UIView <UITextInputTraits> *) object
 * @param objectSuperview A UIView that contains text inputs, but not equals superview of 
 * object parameter
 * @param andReidentifyInputViews A Boolean, that indicates to reidentify or not other objects
 * (`YES` - reidentify, 'NO' - not)
 */
- (void)setObject:(UIView <UITextInputTraits> *)object locatedInSuperview:(UIView *)objectSuperview andReidentifyInputViews:(BOOL)reidentifyInputViews;

/**
 * Reidentifying subviews for objectSuperview parameter,
 * that confirms to (UIView <UITextInputTraits> *) and can became first responder and not hidden.
 *
 * Recomended to use, when you need to update keyboard input accessory view for current object,
 * and changed accessability (enabled, hidden) of other text inputs for some 
 * (UIView <UITextInputTraits> *) components or added/deleted ones on current objectSuperview
 */
- (void)reidentifyInputViewsAndUpdateNavigationAviability;

/**
 * @discussion Returns a Boolean value indicating whether current object is not last text input
 * @return NO if current object is the last text input view for current objectSuperview, YES -
 * current object not last, and there are some text input views after it
 */
- (BOOL)isThereNextTextInput;

/**
 * A Boolean value that indicates whether will handle target action for "Next"/"Previous" buttons
 * located in segmented control (YES) or not (NO).
 *
 * If NO it will just delegate navigation events, if it can.
 *
 * If YES it will be searching for next/previous UIView <UITextInputTraits>, that can become
 * a first responder and not hidden.
 *
 * Default value is YES
 */
@property (nonatomic) BOOL handlePreviousNextButtons;

/**
 * A Boolean value that indicates whether will handle target action for "Done" button
 *
 * If NO it will just delegate navigation events, if it can.
 *
 * If YES it will hide keyboard, if current object (UIView <UITextInputTraits> *) is not last.
 * If current object is last it will try to run textFieldShouldReturn: metod in delegate for
 * object, if delegate conforms to protocol <UITextFieldDelegate> and can perfom that selector.
 *
 * Default value is YES
 */
@property (nonatomic) BOOL handleDoneButton;

/**
 * A Boolean value that indicates is "Next"/"Previous" buttons that located in segmented control
 * is on the left side of toolbar
 *
 * If setted to NO it show "Next"/"Previous" buttons on the right side of toolbar
 *
 * Default value is YES
 */
@property (nonatomic) BOOL navigationButtonsOnTheLeft;

/**
 * A Boolean value that indicates whether will handle target action for "Done" button
 *
 * If NO it will handle next/previous item actions & aviability if them using 
 * NSArray of (UIView <UITextInputTraits> *)objects.
 *
 * If YES it handle next/previous item actions & aviability if them using searh for all objects 
 * in view with tag, that confirms to (UIView <UITextInputTraits> *) pointer. It's slow,
 * and sometimes buggy.
 */
@property (nonatomic) BOOL navigateByTags;

@end
