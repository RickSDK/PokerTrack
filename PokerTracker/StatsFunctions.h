//
//  StatsFunctions.h
//  PokerTracker
//
//  Created by Rick Medved on 11/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MultiLineDetailCellWordWrap.h"


@interface StatsFunctions : NSObject {

}

+(UITableViewCell *)statsBreakdown:(UITableView *)tableView CellIdentifier:(NSString *)CellIdentifier title:(NSString *)title stats:(NSArray *)stats;
+(UITableViewCell *)mainChartCell:(UITableView *)tableView CellIdentifier:(NSString *)CellIdentifier chartImageView:(UIImageView *)chartImageView;
+(MultiLineDetailCellWordWrap *)quarterlyStats:(UITableView *)tableView CellIdentifier:(NSString *)CellIdentifier title:(NSString *)title statsArray:(NSArray *)statsArray;

@end
