//
//  ViewController.m
//  QuickLook
//
//  Created by Paul Jackson on 24/02/2017.
//  Copyright © 2017 Paul Jackson. All rights reserved.
//

#import "ViewController.h"

@import QuickLook;

/*
 *  Quicklook Preview Item
 */
@interface PreviewItem : NSObject <QLPreviewItem>
@property(readonly, nullable, nonatomic) NSURL      * previewItemURL;
@property(readonly, nullable, nonatomic) NSString   * previewItemTitle;
@end
@implementation PreviewItem
- (instancetype)initPreviewURL:(NSURL *)docURL WithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        _previewItemURL = [docURL copy];
        _previewItemTitle = [title copy];
    }
    return self;
}
@end

/*
 *  QuickLook Datasource for rending PDF docs
 */
@interface PDFDataSource : NSObject <QLPreviewControllerDataSource>
@property (strong, nonatomic) PreviewItem *item;
@end
@implementation PDFDataSource
- (instancetype)initWithPreviewItem:(PreviewItem *)item {
    self = [super init];
    if (self) {
        _item = item;
    }
    return self;
}
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}
- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.item;
}
@end

@interface ViewController ()
@property (strong, nonatomic) PDFDataSource *pdfDatasource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    /*
     *  get the path to the pdf resource.
     */

    NSString *path = [[NSBundle mainBundle] pathForResource:@"article" ofType:@"pdf"];
    NSURL *docURL = [NSURL fileURLWithPath:path];


    /*
     *  create the Quicklook controller.
     */

    QLPreviewController *qlController = [[QLPreviewController alloc] init];

    PreviewItem *item = [[PreviewItem alloc] initPreviewURL:docURL WithTitle:@"Article"];
    self.pdfDatasource = [[PDFDataSource alloc] initWithPreviewItem:item];
    qlController.dataSource = self.pdfDatasource;


    /*
     *  present the document.
     */

    [self presentViewController:qlController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
