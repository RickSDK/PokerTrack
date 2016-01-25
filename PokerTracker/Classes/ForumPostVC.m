//
//  ForumPostVC.m
//  PokerTracker
//
//  Created by Rick Medved on 6/3/13.
//
//

#import "ForumPostVC.h"
#import "ForumCategoryVC.h"
#import "ForumCreateVC.h"
#import "WebServicesFunctions.h"
#import "ProjectFunctions.h"
#import "ForumCell.h"
#import "UserSummaryVC.h"
#import "MultiLineDetailCellWordWrap.h"
#import "QuadWithImageTableViewCell.h"

@interface ForumPostVC ()

@end

@implementation ForumPostVC
@synthesize mainTableView, activityIndicator, titleLabel, userLabel, locationLabel, dateLabel, bodyTextView, playerImageButton;


@synthesize managedObjectContext, forumPostings;
@synthesize category, postId, masterPostId, user_id, risked, profit, postSelectedFlg, selectAllFlg, postSelectedRow;
@synthesize postStr, replyBody;
@synthesize postTitle, postBody, postUser, postLoc, postDate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    
    if(indexPath.section==0 && indexPath.row==0) {
        ForumCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell==nil)
            cell = [[ForumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.repliesLabel.alpha=0;
        cell.repliesNumber.alpha=0;
        cell.bodyLabel.alpha=0;
        cell.userLabel.alpha=0;
        cell.dateLabel.alpha=0;
        NSArray *titles = [NSArray arrayWithObjects:@"Announcements", @"General", @"Strategy", @"Bad Beats", @"Whoa!", nil];
        cell.textLabel.text=[titles objectAtIndex:category];
        cell.backgroundColor = [UIColor colorWithRed:0 green:.5 blue:0 alpha:1];
        cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"greenGradient.png"]];
        cell.textLabel.textColor = [UIColor colorWithRed:1 green:.8 blue:.4 alpha:1];
        cell.accessoryType= UITableViewCellAccessoryNone;

        return cell;
    }
    if(indexPath.section==0 && indexPath.row==1) {
        MultiLineDetailCellWordWrap *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell==nil)
            cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:cellIdentifier
                                                              withRows:1
                                                       labelProportion:0];
        
        cell.mainTitle = self.postTitle;
        cell.titleTextArray = [NSArray arrayWithObject:@""];
        cell.fieldTextArray = [NSArray arrayWithObject:@"Loading..."];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if([self.postBody length]>0)
            cell.fieldTextArray = [NSArray arrayWithObject:[NSString stringWithFormat:@"%@", self.postBody]];
       
        return cell;
    }
    
    if(indexPath.section==0 && indexPath.row==2) {
        QuadWithImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell==nil)
            cell = [[QuadWithImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.aa.text = self.postUser;
        cell.bb.text = self.postLoc;
        cell.cc.text = self.postDate;
        
        cell.backgroundColor= [UIColor blackColor];
        cell.aaColor = [UIColor colorWithRed:1 green:.8 blue:.4 alpha:1];
        cell.bbColor = [UIColor whiteColor];
        cell.ccColor = [UIColor whiteColor];
        
        if(risked>0) {
          cell.leftImage.image = [ProjectFunctions getPlayerTypeImage:risked winnings:profit];
        }
        
        return cell;
    }
    
    if(selectAllFlg || (postSelectedFlg && postSelectedRow==indexPath.row)) {
        cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection2x%dRow%d", (int)indexPath.section, (int)indexPath.row];
        MultiLineDetailCellWordWrap *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(cell==nil)
            cell = [[MultiLineDetailCellWordWrap alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:cellIdentifier
                                                              withRows:1
                                                       labelProportion:0];
        


        NSString *post = [self.forumPostings objectAtIndex:indexPath.row];
        
        NSArray *parts = [post componentsSeparatedByString:@"|"];
        if([parts count]>11) {
            cell.mainTitle=[parts objectAtIndex:5];
            cell.alternateTitle=[parts objectAtIndex:7];
            cell.titleTextArray = [NSArray arrayWithObject:@""];
            cell.fieldTextArray = [NSArray arrayWithObject:[parts objectAtIndex:8]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    ForumCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell==nil)
	    cell = [[ForumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    NSString *post = [self.forumPostings objectAtIndex:indexPath.row];

    NSArray *parts = [post componentsSeparatedByString:@"|"];
    if([parts count]>11) {
        cell.titleLabel.text=[NSString stringWithFormat:@"Reply #%d", (int)indexPath.row+1];
        cell.userLabel.text=[parts objectAtIndex:5];
        cell.dateLabel.text=[parts objectAtIndex:7];
        int minutes = [[parts objectAtIndex:6] intValue];
        int replies = [[parts objectAtIndex:9] intValue];
        int userRisked = [[parts objectAtIndex:10] intValue];
        int userprofit = [[parts objectAtIndex:11] intValue];
        if(replies>0) {
            cell.repliesNumber.text=[parts objectAtIndex:9];
        } else {
            cell.repliesLabel.alpha=0;
            cell.repliesNumber.alpha=0;
        }
        if(minutes<720)
            cell.dateLabel.text=@"Today";
        cell.bodyLabel.text=[parts objectAtIndex:8];
        if([@"Y" isEqualToString:[parts objectAtIndex:4]])
            cell.mainImg.image = [UIImage imageNamed:@"new.png"];
        else {
            cell.mainImg.image = [UIImage imageNamed:@"IconImg.png"];
            if(risked>0) {
                cell.mainImg.image = [ProjectFunctions getPlayerTypeImage:userRisked winnings:userprofit];
            }
        }
    }
    cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"orngGrad.png"]];
 	cell.accessoryType= UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ForumPostVC *detailViewController = [[ForumPostVC alloc] initWithNibName:@"ForumPostVC" bundle:nil];
    detailViewController.category=category;
    detailViewController.masterPostId=masterPostId;
    detailViewController.postStr=[self.forumPostings objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section==0)
        return 3;
    
    return [self.forumPostings count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section==0 && indexPath.row==0)
        return 30;
    if(indexPath.section==0 && indexPath.row==2)
        return 44;
    
    
	if (indexPath.section == 0 && indexPath.row == 1) {
        NSArray *data = [NSArray arrayWithObject:@"dummy"];
        if([self.postBody length]>10)
            data = [NSArray arrayWithObject:self.postBody];
		return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:data
                                                                   tableView:tableView
                                                        labelWidthProportion:0]+20;
	}
    
    if(selectAllFlg || (postSelectedFlg && postSelectedRow==indexPath.row && indexPath.section==1)) {
        NSString *body = [self postBodyAtIndex:(int)indexPath.row];

        NSArray *data = [NSArray arrayWithObject:body];
 		return [MultiLineDetailCellWordWrap cellHeightWithNoMainTitleForData:data
                                                                   tableView:tableView
                                                        labelWidthProportion:0]+20;
    }
	return 44;
}

-(NSString *)postBodyAtIndex:(int)index {
    NSString *result = @"dummy";
    if([self.forumPostings count]>index) {
        NSString *post = [self.forumPostings objectAtIndex:index];
        
        NSArray *parts = [post componentsSeparatedByString:@"|"];
        if([parts count]>11) {
            result = [parts objectAtIndex:8];
        }
    }

    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0)
        postSelectedFlg=NO;
    
    if(indexPath.section==0 && indexPath.row==0) {
        ForumCategoryVC *detailViewController = [[ForumCategoryVC alloc] initWithNibName:@"ForumCategoryVC" bundle:nil];
        detailViewController.managedObjectContext = managedObjectContext;
        detailViewController.category=category;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
    if(indexPath.section==0 && indexPath.row==1) {
        selectAllFlg=!selectAllFlg;
    }
    
    if(indexPath.section==0 && indexPath.row==2) {
		return;
		
        UserSummaryVC *detailViewController = [[UserSummaryVC alloc] initWithNibName:@"UserSummaryVC" bundle:nil];
        detailViewController.managedObjectContext=managedObjectContext;
        detailViewController.friend_id=user_id;
        detailViewController.selectedSegment=0;
        detailViewController.user=@"00999803<xx>Jun 2013|3 (0W, 3L) 0%|3|370|-197|-3|46|392<xx>Rick|3|rickmedved@hotmail.com|Lynnwood|WA|USA|3|self|N|$|Version 7.6 (iPhone)<xx>06/07/2013 05:00:00 PM|120|100|98|Tulalip Casino|170|Cash|N|Hold'em|$1/$3|No-Limit|06/07/2013 07:50:19 PM|06/07/2013 07:50:18 PM|$|48.088244:-122.189383|0|N|<aa>Rick|3|rickmedved@hotmail.com|Lynnwood|WA|USA|3|self|N|$|Version 7.6 (iPhone)<xx>Last10|10 (4W, 6L) 40%|10|1120|179|-3|115|1640<xx>2013|42 (20W, 22L) 47%|42|4590|1301|-3|128|7918<xx>Jun 2013|3 (0W, 3L) 0%|3|370|-197|-3|46|392<xx>06/07/2013 05:00:00 PM|120|100|98|Tulalip Casino|170|Cash|N|Hold'em|$1/$3|No-Limit|06/07/2013 07:50:19 PM|06/07/2013 07:50:18 PM|$|48.088244:-122.189383|0|N|<xx>03/16/2013|-77:03/21/2013|6:03/22/2013|144:03/22/2013|96:03/23/2013|213:03/29/2013|1064:04/04/2013|100:04/10/2013|-120:04/11/2013|-30:04/14/2013|-34:04/18/2013|60:04/19/2013|-120:04/23/2013|-38:04/25/2013|-30:04/26/2013|181:04/29/2013|58:05/02/2013|-120:05/06/2013|122:05/09/2013|20:05/10/2013|-120:05/12/2013|-120:05/14/2013|-37:05/18/2013|171:05/19/2013|114:05/28/2013|348:06/03/2013|-50:06/06/2013|-30:06/07/2013|-117:<xx>06/03/2013|-50:06/06/2013|-30:06/07/2013|-117:<xx>05/09/2013|20:05/10/2013|-120:05/12/2013|-120:05/14/2013|-37:05/18/2013|171:05/19/2013|114:05/28/2013|348:06/03/2013|-50:06/06/2013|-30:06/07/2013|-117";
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    if(indexPath.section==1) {
        postSelectedFlg=!postSelectedFlg;
        self.replyBody = [self postBodyAtIndex:(int)indexPath.row];
    }
    postSelectedRow=(int)indexPath.row;
    [mainTableView reloadData];
}

-(void)replyButtonClicked:(id)sender {
    if([ProjectFunctions isLiteVersion]) {
        [ProjectFunctions showAlertPopup:@"Notice" message:@"Users of Lite version cannot post messages. Please upgrade!"];
        return;
    }
    ForumCreateVC *detailViewController = [[ForumCreateVC alloc] initWithNibName:@"ForumCreateVC" bundle:nil];
    detailViewController.category=category;
    detailViewController.postStr = self.postStr;
    detailViewController.postId = masterPostId;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) playerButtonPressed: (id) sender
{
    UserSummaryVC *detailViewController = [[UserSummaryVC alloc] initWithNibName:@"UserSummaryVC" bundle:nil];
    detailViewController.managedObjectContext=managedObjectContext;
    detailViewController.friend_id=user_id;
    detailViewController.selectedSegment=1;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)loadForum
{
	@autoreleasepool {
    
        [self.forumPostings removeAllObjects];
        
        
        NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"postId", nil];
	NSString *username = [ProjectFunctions getUserDefaultValue:@"userName"];
	NSString *password = [ProjectFunctions getUserDefaultValue:@"password"];
	NSArray *valueList = [NSArray arrayWithObjects:username, password, [NSString stringWithFormat:@"%d", postId], nil];
        
 	NSString *webAddr = @"http://www.appdigity.com/poker/forumGetPost.php";
	NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
        NSLog(@"responseStr: %@", responseStr);
        if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
            NSArray *parts1 = [responseStr componentsSeparatedByString:@"<br>"];
            if([parts1 count]>2) {
                NSArray *postings = [[parts1 objectAtIndex:2] componentsSeparatedByString:@"<b>"];
                [self.forumPostings addObjectsFromArray:postings];
               
                NSArray *postParts = [[parts1 objectAtIndex:1] componentsSeparatedByString:@"|"];
                if([postParts count]>10) {
                    self.postTitle = [postParts objectAtIndex:3];
                    self.postBody = [postParts objectAtIndex:4];
                    self.postDate = [postParts objectAtIndex:5];
                    self.postUser = [postParts objectAtIndex:6];
                    self.postLoc = [postParts objectAtIndex:7];
                    
                    self.risked = [[postParts objectAtIndex:9] intValue];
                    self.profit = [[postParts objectAtIndex:10] intValue];
                    
                    [titleLabel performSelectorOnMainThread:@selector(setText: ) withObject:[postParts objectAtIndex:3] waitUntilDone:YES];
                    [userLabel performSelectorOnMainThread:@selector(setText: ) withObject:[postParts objectAtIndex:6] waitUntilDone:YES];
                    [locationLabel performSelectorOnMainThread:@selector(setText: ) withObject:[postParts objectAtIndex:7] waitUntilDone:YES];
                    [dateLabel performSelectorOnMainThread:@selector(setText: ) withObject:[postParts objectAtIndex:5] waitUntilDone:YES];
                    [bodyTextView performSelectorOnMainThread:@selector(setText: ) withObject:[postParts objectAtIndex:4] waitUntilDone:YES];
                    user_id = [[postParts objectAtIndex:8] intValue];
                }
            }
        }
        [self.forumPostings removeLastObject];
 	
        
	[activityIndicator stopAnimating];
        
        [mainTableView reloadData];
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}



-(void)refreshPage {
    [activityIndicator startAnimating];
	[self performSelectorInBackground:@selector(loadForum) withObject:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(BOOL)shouldAutorotate
{
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.forumPostings = [[NSMutableArray alloc] initWithCapacity:4];
    

    self.replyBody = [[NSString alloc] init];
    self.postTitle = [[NSString alloc] init];
    self.postBody = [[NSString alloc] init];
    self.postUser = [[NSString alloc] init];
    self.postLoc = [[NSString alloc] init];
    self.postDate = [[NSString alloc] init];

    
    [titleLabel performSelectorOnMainThread:@selector(setText: ) withObject:@"" waitUntilDone:YES];
    [userLabel performSelectorOnMainThread:@selector(setText: ) withObject:@"" waitUntilDone:YES];
    [locationLabel performSelectorOnMainThread:@selector(setText: ) withObject:@"" waitUntilDone:YES];
    [dateLabel performSelectorOnMainThread:@selector(setText: ) withObject:@"" waitUntilDone:YES];
    [bodyTextView performSelectorOnMainThread:@selector(setText: ) withObject:@"" waitUntilDone:YES];

    NSArray *parts = [self.postStr componentsSeparatedByString:@"|"];
    if([parts count]>2)
        postId = [[parts objectAtIndex:2] intValue];
    
    if(masterPostId==0)
        masterPostId=postId;

    NSArray *titles = [NSArray arrayWithObjects:@"Announcements", @"General", @"Strategy", @"Bad Beats", nil];
    [self setTitle:[titles objectAtIndex:category]];

    NSString *emailAddress = [ProjectFunctions getUserDefaultValue:@"emailAddress"];
    
    if(category>0 || [@"rickmedved@hotmail.com" isEqualToString:emailAddress] || [@"robbmedved@yahoo.com" isEqualToString:emailAddress]) {
        UIBarButtonItem *replyButton = [[UIBarButtonItem alloc] initWithTitle:@"Reply" style:UIBarButtonItemStylePlain target:self action:@selector(replyButtonClicked:)];
        self.navigationItem.rightBarButtonItem = replyButton;
    }
    
    [self refreshPage];
    
}




@end
