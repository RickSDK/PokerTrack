//
//  ImageCell.h
//  PokerTracker
//
//  Created by Rick Medved on 7/8/13.
//
//

#import <UIKit/UIKit.h>

@interface ImageCell : UITableViewCell {
    UILabel *nameLabel;
    UILabel *cityLabel;

}

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *cityLabel;

@end
