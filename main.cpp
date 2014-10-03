//
//  main.cpp
//  ThirdOpencvApp
//
//  Created by Yu Wang on 9/29/14.
//  Copyright (c) 2014 Yu. All rights reserved.
//

#include <iostream>
#include <array>
#include <opencv2/core/core.hpp>
#include <opencv2/features2d/features2d.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/legacy/legacy.hpp>
#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/nonfree/nonfree.hpp>
#include <opencv2/nonfree/features2d.hpp>

#include <vector>

using namespace std;
using namespace cv;

// run main function
int main(int argc, char *argv[])
{

    // load images
    Mat tmp = cv::imread( "set1/pic1.jpg", CV_LOAD_IMAGE_COLOR );
    Mat in  = cv::imread( "set1/pic2.jpg", CV_LOAD_IMAGE_COLOR );
    
    
    // SIFT feature detector and feature extractor
    SiftFeatureDetector detector( 0.02, 5.0 );
    SiftDescriptorExtractor extractor( 2.0 );

    // Feature detection
    
    vector<KeyPoint> keypoints1, keypoints2;
    detector.detect( tmp, keypoints1 );
    detector.detect( in, keypoints2 );
    
    // Feature display
    Mat feat1,feat2;
    drawKeypoints(tmp,keypoints1,feat1,Scalar(255, 255, 255),DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
    drawKeypoints(in,keypoints2,feat2,Scalar(255, 255, 255),DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
    imwrite( "feat1.png", feat1 );
    imwrite( "feat2.png", feat2 );
    
    // Feature descriptor computation
    Mat descriptor1,descriptor2;
    extractor.compute( tmp, keypoints1, descriptor1 );
    extractor.compute( in, keypoints2, descriptor2 );
    
    // corresponded points
    vector<DMatch> matches;
    
    // L2 distance based matching. Brute Force Matching
    BruteForceMatcher<L2<float>> matcher;
    
    // display of corresponding points
    matcher.match( descriptor1, descriptor2, matches );
    
    
    double max_dist = 0; double min_dist = 100;
    
    //-- Quick calculation of max and min distances between keypoints
    for( int i = 0; i < descriptor1.rows; i++ )
    {
        double dist = matches[i].distance;
        cout << dist << endl;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
    
    //-- Draw only "good" matches when the threshold is above a certain value
    std::vector< DMatch > good_matches;
    
    for( int i = 0; i < descriptor1.rows; i++ ){
        if( matches[i].distance <= max(2.25*min_dist, 0.01))
        { good_matches.push_back( matches[i]); }
    }
    
    //-- Draw only "good" matches
    Mat img_matches;
    drawMatches( tmp, keypoints1, in, keypoints2,
                good_matches, img_matches, Scalar::all(-1), Scalar::all(-1),
                vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );
    
    // matching result
    
    // output file
    imwrite( "result.png", img_matches);
    
    // display the result
    namedWindow("SIFT", CV_WINDOW_AUTOSIZE );
    imshow("SIFT", img_matches);
    waitKey(0); //press any key to quit
    
    return 0;
}