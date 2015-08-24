//
//  TextEditCell.h
//  BASE
//
//

#import <UIKit/UIKit.h>


@interface TextEditCell : UITableViewCell {

	UITextField *textField;
	
	//set only one of these.  
	CGFloat labelProportion;
	int fixedTextFieldWidth;   //width of textField ... set if want to keep the width of the textField constant regardless of cell width
}

@property (readonly) UITextField *textField;
@property (assign) CGFloat labelProportion;
@property (assign) int fixedTextFieldWidth;

@end
