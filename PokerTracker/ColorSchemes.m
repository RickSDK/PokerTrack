//
//  ColorSchemes.m
//  PokerTracker
//
//  Created by Rick Medved on 8/17/17.
//
//

#import "ColorSchemes.h"
#import "ThemeColorObj.h"

@implementation ColorSchemes

+(NSArray *)disneyThemes {
	return [NSArray arrayWithObjects:
			[ThemeColorObj themeWithName:@"Snow White"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:0.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:26.0/255 green:89.0/255 blue:255.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:255.0/255 green:0.0/255 blue:0.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:161.0/255 blue:162.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Mickey Mouse"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:200.0/255 blue:0.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:255.0/255 green:0.0/255 blue:0.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:25.0/255 green:25.0/255 blue:25.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Donald Duck"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:200.0/255 blue:0.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:20.0/255 green:100.0/255 blue:240.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:255.0/255 green:0.0/255 blue:0.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Minie Mouse"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:0.0/255 blue:255.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:155.0/255 green:0.0/255 blue:155.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:55.0/255 green:0.0/255 blue:55.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Frozen"
				   primaryColor:[UIColor colorWithRed:200.0/255 green:240.0/255 blue:255.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:(6/255.0) green:(122/255.0) blue:(180/255.0) alpha:1.0]
					navBarColor:[UIColor colorWithRed:100.0/255 green:230.0/255 blue:255.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:161.0/255 green:181.0/255 blue:205.0/255 alpha:1]],
			nil];
}

+(NSArray *)afcEastThemes {
	return [NSArray arrayWithObjects:
			[ThemeColorObj themeWithName:@"New England Patriots"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:12.0/255 green:35.0/255 blue:64.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:200.0/255 green:16.0/255 blue:46.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Miami Dolphins"
				   primaryColor:[UIColor colorWithRed:245.0/255 green:130.0/255 blue:32.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:142.0/255 blue:151.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:0.0/255 green:87.0/255 blue:120.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"New York Jets"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:12.0/255 green:55.0/255 blue:29.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:12.0/255 green:55.0/255 blue:29.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Buffalo Bills"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:200.0/255 green:16.0/255 blue:46.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:12.0/255 green:46.0/255 blue:130.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			nil];
}

+(NSArray *)afcNorthThemes {
	return [NSArray arrayWithObjects:
			[ThemeColorObj themeWithName:@"Baltimore Ravins"
				   primaryColor:[UIColor colorWithRed:208.0/255 green:178.0/255 blue:64.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:26.0/255 green:25.0/255 blue:95.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:16.0/255 green:24.0/255 blue:32.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Cincinnati Bengals"
				   primaryColor:[UIColor colorWithRed:252.0/255 green:76.0/255 blue:2.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:16.0/255 green:24.0/255 blue:32.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:16.0/255 green:24.0/255 blue:32.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Pittsburgh Steelers"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:184.0/255 blue:28.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:16.0/255 green:24.0/255 blue:32.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:16.0/255 green:24.0/255 blue:32.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Cleveland Browns"
				   primaryColor:[UIColor colorWithRed:235.0/255 green:51.0/255 blue:0.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:56.0/255 green:47.0/255 blue:45.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:56.0/255 green:47.0/255 blue:45.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			nil];
}

+(NSArray *)afcSouthThemes {
	return [NSArray arrayWithObjects:
			[ThemeColorObj themeWithName:@"Houston Texans"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:166.0/255 green:25.0/255 blue:46.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:9.0/255 green:31.0/255 blue:44.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Jacksonville Jaguars"
				   primaryColor:[UIColor colorWithRed:212.0/255 green:159.0/255 blue:18.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:96.0/255 blue:115.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:16.0/255 green:24.0/255 blue:32.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Indianapolis Colts"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:20.0/255 blue:137.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:0.0/255 green:20.0/255 blue:137.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Tennessee Titans"
				   primaryColor:[UIColor colorWithRed:65.0/255 green:143.0/255 blue:222.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:200.0/255 green:16.0/255 blue:46.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:12.0/255 green:35.0/255 blue:64.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:191.0/255 green:192.0/255 blue:191.0/255 alpha:1]],
			nil];
}

+(NSArray *)afcWestThemes {
	return [NSArray arrayWithObjects:
			[ThemeColorObj themeWithName:@"Kansas City Chiefs"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:184.0/255 blue:28.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:200.0/255 green:16.0/255 blue:46.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:200.0/255 green:16.0/255 blue:46.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Denver Broncos"
				   primaryColor:[UIColor colorWithRed:252.0/255 green:76.0/255 blue:2.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:12.0/255 green:35.0/255 blue:64.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:12.0/255 green:35.0/255 blue:64.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Oakland Raiders"
				   primaryColor:[UIColor colorWithRed:191.0/255 green:192.0/255 blue:191.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:16.0/255 green:24.0/255 blue:32.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:16.0/255 green:24.0/255 blue:32.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:191.0/255 green:192.0/255 blue:191.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Los Angeles Chargers"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:184.0/255 blue:28.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:114.0/255 blue:206.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:12.0/255 green:35.0/255 blue:64.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			nil];
}

+(NSArray *)nfcEastThemes {
	return [NSArray arrayWithObjects:
			[ThemeColorObj themeWithName:@"New York Giants"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:30.0/255 blue:98.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:166.0/255 green:25.0/255 blue:46.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:162.0/255 green:170.0/255 blue:173.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Philadelphia Eagles"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:72.0/255 blue:81.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:16.0/255 green:24.0/255 blue:32.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:134.0/255 green:147.0/255 blue:151.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Washington Redskins"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:205.0/255 blue:0.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:134.0/255 green:38.0/255 blue:51.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:134.0/255 green:38.0/255 blue:51.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Dallas Cowboys"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:53.0/255 blue:148.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:4.0/255 green:30.0/255 blue:66.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:134.0/255 green:147.0/255 blue:151.0/255 alpha:1]],
			nil];
}

+(NSArray *)nfcNorthThemes {
	return [NSArray arrayWithObjects:
			[ThemeColorObj themeWithName:@"Minnesota Vikings"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:184.0/255 blue:28.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:84.0/255 green:41.0/255 blue:109.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:84.0/255 green:41.0/255 blue:109.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Green Bay Packers"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:184.0/255 blue:28.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:23.0/255 green:94.0/255 blue:34.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:23.0/255 green:94.0/255 blue:34.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Detroit Lions"
				   primaryColor:[UIColor colorWithRed:162.0/255 green:170.0/255 blue:173.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:105.0/255 blue:177.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Chicago Bears"
				   primaryColor:[UIColor colorWithRed:220.0/255 green:68.0/255 blue:5.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:5.0/255 green:28.0/255 blue:44.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:5.0/255 green:28.0/255 blue:44.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			nil];
}

+(NSArray *)nfcSouthThemes {
	return [NSArray arrayWithObjects:
			[ThemeColorObj themeWithName:@"Tampa Bay Buccaneers"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:130.0/255 blue:0.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:61.0/255 green:57.0/255 blue:53.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:200.0/255 green:16.0/255 blue:46.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:140.0/255 green:144.0/255 blue:147.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"New Orleans Saints"
				   primaryColor:[UIColor colorWithRed:162.0/255 green:141.0/255 blue:91.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:16.0/255 green:24.0/255 blue:31.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:16.0/255 green:24.0/255 blue:31.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Carolina Panthers"
				   primaryColor:[UIColor colorWithRed:0.0/255 green:133.0/255 blue:202.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:16.0/255 green:24.0/255 blue:32.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:16.0/255 green:24.0/255 blue:32.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Atlanta Falcons"
				   primaryColor:[UIColor colorWithRed:166.0/255 green:25.0/255 blue:46.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:16.0/255 green:24.0/255 blue:32.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:16.0/255 green:24.0/255 blue:32.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:140.0/255 green:139.0/255 blue:137.0/255 alpha:1]],
			nil];
}

+(NSArray *)nfcWestThemes {
	return [NSArray arrayWithObjects:
			[ThemeColorObj themeWithName:@"Seattle Seahawks"
				   primaryColor:[UIColor colorWithRed:77.0/255 green:255.0/255 blue:0.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:36.0/255 green:89.0/255 blue:152.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:0.0/255 green:21.0/255 blue:51.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:161.0/255 blue:162.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"San Francisco 49ers"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:157.0/255 green:42.0/255 blue:70.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:137.0/255 green:108.0/255 blue:78.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:161.0/255 blue:162.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Arizona Cardinals"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:205.0/255 blue:0.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:155.0/255 green:39.0/255 blue:67.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:155.0/255 green:39.0/255 blue:67.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Los Angeles Rams"
				   primaryColor:[UIColor colorWithRed:199.0/255 green:169.0/255 blue:115.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:4.0/255 green:30.0/255 blue:66.0/255 alpha:1]
					navBarColor:[UIColor colorWithRed:4.0/255 green:30.0/255 blue:66.0/255 alpha:1]
					  grayColor:[UIColor colorWithRed:155.0/255 green:161.0/255 blue:162.0/255 alpha:1]],
			nil];
}

+(NSArray *)mlbThemes {
	return [NSArray arrayWithObjects:
			[ThemeColorObj themeWithName:@"Seattle Mariners"
				   primaryColor:[UIColor colorWithRed:28.0/255 green:139.0/255 blue:133.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:49.0/255 blue:102.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:49.0/255 blue:102.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:192.0/255 green:192.0/255 blue:192.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Oakland A's"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:178.0/255 blue:0.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:72.0/255 blue:58.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:72.0/255 blue:58.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:155.0/255 green:161.0/255 blue:162.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"New York Yankees"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:28.0/255 green:40.0/255 blue:65.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:28.0/255 green:40.0/255 blue:65.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:128.0/255 green:128.0/255 blue:128.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Arizona Diamondbacks"
				   primaryColor:[UIColor colorWithRed:219.0/255 green:206.0/255 blue:172.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:9.0/255 green:173.0/255 blue:173.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:167.0/255 green:25.0/255 blue:48.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:155.0/255 green:155.0/255 blue:155.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Miami Marlins"
				   primaryColor:[UIColor colorWithRed:252.0/255 green:222.0/255 blue:4.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:249.0/255 green:66.0/255 blue:59.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:4.0/255 green:130.0/255 blue:204.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:164.0/255 green:170.0/255 blue:172.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"San Francisco Giants"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:253.0/255 blue:208.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:251.0/255 green:91.0/255 blue:31.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:164.0/255 green:164.0/255 blue:164.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Tampa Bay Rays"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:215.0/255 blue:0.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:40.0/255 blue:93.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:121.0/255 green:189.0/255 blue:238.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:164.0/255 green:164.0/255 blue:164.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Boston Red Sox"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:198.0/255 green:12.0/255 blue:48.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:34.0/255 blue:68.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:164.0/255 green:164.0/255 blue:164.0/255 alpha:1]],
			nil];
}
+(NSArray *)nbaThemes {
	return [NSArray arrayWithObjects:
			[ThemeColorObj themeWithName:@"Chicago Bulls"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:206.0/255 green:17.0/255 blue:65.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Los Angeles Lakers"
				   primaryColor:[UIColor colorWithRed:253.0/255 green:185.0/255 blue:39.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:85.0/255 green:37.0/255 blue:130.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:85.0/255 green:37.0/255 blue:130.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Golden State Warriors"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:199.0/255 blue:44.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:107.0/255 blue:182.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:107.0/255 blue:182.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Cleveland Cavaliers"
				   primaryColor:[UIColor colorWithRed:253.0/255 green:187.0/255 blue:48.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:134.0/255 green:0.0/255 blue:56.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:45.0/255 blue:98.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Milwaukee Bucks"
				   primaryColor:[UIColor colorWithRed:238.0/255 green:225.0/255 blue:198.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:71.0/255 blue:27.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:119.0/255 blue:192.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			nil];
}
+(NSArray *)ncaaThemes {
	return [NSArray arrayWithObjects:
			[ThemeColorObj themeWithName:@"Washington"
				   primaryColor:[UIColor colorWithRed:145.0/255 green:123.0/255 blue:76.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:51.0/255 green:0.0/255 blue:111.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:51.0/255 green:0.0/255 blue:111.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:232.0/255 green:211.0/255 blue:162.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Miami"
				   primaryColor:[UIColor colorWithRed:244.0/255 green:115.0/255 blue:33.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:80.0/255 blue:48.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:80.0/255 blue:48.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Kansas"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:80.0/255 blue:186.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:232.0/255 green:0.0/255 blue:13.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Michigan"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:199.0/255 blue:44.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:4.0/255 green:30.0/255 blue:66.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:4.0/255 green:30.0/255 blue:66.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:155.0/255 green:161.0/255 blue:162.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Notre Dame"
				   primaryColor:[UIColor colorWithRed:200.0/255 green:150.0/255 blue:0.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:12.0/255 green:35.0/255 blue:64.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:12.0/255 green:35.0/255 blue:64.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Oregon"
							primaryColor:[UIColor colorWithRed:254.0/255 green:225.0/255 blue:35.0/255 alpha:1]
							themeBGColor:[UIColor colorWithRed:18.0/255 green:71.0/255 blue:52.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:18.0/255 green:71.0/255 blue:52.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Louisville"
							primaryColor:[UIColor colorWithRed:253.0/255 green:185.0/255 blue:19.0/255 alpha:1]
							themeBGColor:[UIColor colorWithRed:227.0/255 green:27.0/255 blue:35.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:209.0/255 green:211.0/255 blue:212.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Florida State"
							primaryColor:[UIColor colorWithRed:206.0/255 green:184.0/255 blue:136.0/255 alpha:1]
							themeBGColor:[UIColor colorWithRed:120.0/255 green:47.0/255 blue:64.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:209.0/255 green:211.0/255 blue:212.0/255 alpha:1]],
			nil];
}
+(NSArray *)nhlThemes {
	return [NSArray arrayWithObjects:
			[ThemeColorObj themeWithName:@"Boston Bruins"
				   primaryColor:[UIColor colorWithRed:253.0/255 green:185.0/255 blue:48.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Dallas Stars"
				   primaryColor:[UIColor colorWithRed:167.0/255 green:168.0/255 blue:172.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:1.0/255 green:111.0/255 blue:74.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Anaheim Ducks"
				   primaryColor:[UIColor colorWithRed:245.0/255 green:125.0/255 blue:49.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:182.0/255 green:152.0/255 blue:90.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Edmonton Oilers"
				   primaryColor:[UIColor colorWithRed:235.0/255 green:110.0/255 blue:30.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:1.0/255 green:62.0/255 blue:127.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:1.0/255 green:62.0/255 blue:127.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Chicago Blackhawks"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:198.0/255 green:12.0/255 blue:48.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Pittsburgh Penguins"
				   primaryColor:[UIColor colorWithRed:197.0/255 green:179.0/255 blue:88.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"San Jose Sharks"
				   primaryColor:[UIColor colorWithRed:244.0/255 green:144.0/255 blue:30.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:120.0/255 blue:137.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			nil];
}
+(NSArray *)mlsThemes {
	return [NSArray arrayWithObjects:
			[ThemeColorObj themeWithName:@"Seattle Sounders"
				   primaryColor:[UIColor colorWithRed:93.0/255 green:151.0/255 blue:50.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:86.0/255 blue:149.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:19.0/255 green:37.0/255 blue:48.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"LA Galaxy"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:217.0/255 blue:0.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:51.0/255 green:101.0/255 blue:177.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:36.0/255 blue:93.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Atlanta United"
				   primaryColor:[UIColor colorWithRed:137.0/255 green:118.0/255 blue:75.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:157.0/255 green:34.0/255 blue:53.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:45.0/255 green:41.0/255 blue:38.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Houston Dynamo"
				   primaryColor:[UIColor colorWithRed:236.0/255 green:145.0/255 blue:18.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:141.0/255 green:198.0/255 blue:237.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:35.0/255 green:31.0/255 blue:32.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Portland Timbers"
				   primaryColor:[UIColor colorWithRed:234.0/255 green:239.0/255 blue:39.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:72.0/255 blue:18.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:72.0/255 blue:18.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Orlando City SC"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:225.0/255 blue:152.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:97.0/255 green:43.0/255 blue:155.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:97.0/255 green:43.0/255 blue:155.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"New England Revolution"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:198.0/255 green:51.0/255 blue:35.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:34.0/255 green:35.0/255 blue:82.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			nil];
}

+(NSArray *)chineseThemes {
	return [NSArray arrayWithObjects:
			[ThemeColorObj themeWithName:@"Shanghai SIPG F.C."
				   primaryColor:[UIColor colorWithRed:255.0/255 green:210.0/255 blue:0.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:210.0/255 green:0.0/255 blue:0.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:210.0/255 green:0.0/255 blue:0.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Jiangsu Suning F.C."
				   primaryColor:[UIColor colorWithRed:253.0/255 green:185.0/255 blue:39.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:85.0/255 green:37.0/255 blue:130.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:85.0/255 green:37.0/255 blue:130.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Shanghai Shenhua"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:0.0/255 green:66.0/255 blue:130.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:255.0/255 green:0.0/255 blue:0.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Tianjin Quanjian F.C."
				   primaryColor:[UIColor colorWithRed:217.0/255 green:191.0/255 blue:88.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:114.0/255 green:0.0/255 blue:2.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:62.0/255 green:157.0/255 blue:229.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"China National"
				   primaryColor:[UIColor colorWithRed:245.0/255 green:176.0/255 blue:34.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:221.0/255 green:0.0/255 blue:16.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			[ThemeColorObj themeWithName:@"Beijing Sinobo"
				   primaryColor:[UIColor colorWithRed:255.0/255 green:243.0/255 blue:18.0/255 alpha:1]
				   themeBGColor:[UIColor colorWithRed:32.0/255 green:168.0/255 blue:85.0/255 alpha:1]
							 navBarColor:[UIColor colorWithRed:32.0/255 green:168.0/255 blue:85.0/255 alpha:1]
							   grayColor:[UIColor colorWithRed:175.0/255 green:175.0/255 blue:175.0/255 alpha:1]],
			nil];
}

@end
