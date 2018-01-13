//
//  ViewController.m
//  QuickLook
//
//  Created by Paul Jackson on 24/02/2017.
//  Copyright © 2017 Paul Jackson. All rights reserved.
//

#import "ViewController.h"
#import <TargetConditionals.h>

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

        /*
         Unfortunately there's a bug in iOS 11.2 that prevents bundled PDF's from displaying when using
         the QLPreviewController. This appears to only be a problem when attempting to load the PDF on a
         physical device; everything works as expected when running in the simulator.
         */

#if !TARGET_OS_SIMULATOR
        if (@available(iOS 11.2, *)) {
            [self showbundlefiles];
            [self showsupportfiles];
            [self copydoc];
        }
#endif
    }
    return self;
}

/*
 *  helper to show files in the bundle
 */
-(void)showbundlefiles {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString       *bundleRoot = [[NSBundle mainBundle] bundlePath];
    NSArray       *dirContents = [fileManager contentsOfDirectoryAtPath:bundleRoot error:nil];

    NSLog(@"%@\n%@", bundleRoot, dirContents);
}

/*
 *  helper to show files in the Application Support folder
 */
-(void)showsupportfiles {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString      *supportRoot = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSArray       *dirContents = [fileManager contentsOfDirectoryAtPath:supportRoot error:nil];

    NSLog(@"%@\n%@", supportRoot, dirContents);
}

/*
 *  helper to copy resource to a location that the QLPreviewController can see.
 */
-(void)copydoc {
    NSFileManager *fm = [NSFileManager defaultManager];

    /*
     *  folder bookkeeping
     */

    NSString *folderPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    if (![fm fileExistsAtPath:folderPath]) {
        [fm createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:kNilOptions error:nil];
    }

    /*
     *  migrate the target file to a location visible to the QLPreviewController
     */

    NSString *filePath = [folderPath stringByAppendingPathComponent:[_previewItemURL.absoluteString lastPathComponent]];
    if (![fm fileExistsAtPath:filePath]) {
        [fm copyItemAtPath:_previewItemURL.relativePath toPath:filePath error:nil];
    }

    /*
     *  persist the cached location
     */

    _previewItemURL = [NSURL fileURLWithPath:filePath];
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
