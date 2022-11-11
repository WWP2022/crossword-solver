#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <vector>

#define EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))

using namespace std;
using namespace cv;

EXPORT
const char* get_version() {
    return CV_VERSION;
}

EXPORT
int image_processing(char *path) {
    Mat input = imread(path);

    Mat gray_img, edges, kernel;

    // apply some preprocessing before applying Hough transform
    cvtColor(input, gray_img, COLOR_BGR2GRAY);

    Canny(gray_img, edges, 90, 150); // apertureSize = 3 by default

//    kernel = getStructuringElement(MORPH_RECT, Size(3, 3));
//    dilate(edges, edges, kernel); // iterations = 1 by default
//
//    kernel = getStructuringElement(MORPH_RECT, Size(5, 5));
//    erode(edges, edges, kernel); // iterations = 1 by default

    vector<Vec2f> lines;
    HoughLines(edges, lines, 1, CV_PI/180, 400, 0, 0);

    return lines.size();
}
