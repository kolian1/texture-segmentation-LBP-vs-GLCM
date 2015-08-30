Image segmentation via several feature spaces DEMO.
This demo was designed to demonstrate several commonly used feature spaces, in a segmentation task. It was inspired by multiple questions of Matlab File Exchange users addressed via Matlab Answers, and to author’s personal page and email.  
The goal of a segmentation process in image processing is to divide image to elements (segments). When defined and implemented properly, some of the elements may include meaningful elements of the scene- humans, animals, building, vehicles etc. This allows to continue to analyze the image or video stream to get meaningful insight about the filmed scene.
There are multiple segmentation schemes. In short, a classical segmentation scheme is composed of the following stages:
1. Feature space selection, either by hand, using experience and knowledge about problem in hand, or automatic set of features: Harr like Viola Jones windows, LBP, HOG, Color histograms etc…
2. Image transformation to feature space. In many cases a combination of different feature is used.
3. Feature space reduction- to improve both run-time (sometimes dramatically) and segmentation accuracy. PCA is a good example of efficient feature reduction method.
4. Image pixels classification.
5. Spatial/temporal segmentation smoothing- if spatially/temporally continuous segments are assumed.
We have implemented a simplified scheme, omitting some of the above stages.
1. Feature space selection Used feature spaces are: LBP, GLCM, Statistical image moments.
2. Image transformation to feature space. Each feature space is composed of a single feature specified above. In case of color image each color is treated separately, resulting in a larger feature vector. A feature vector if generated of a predefined neighborhood of each chosen pixel. Matab "blockproc" function is used to acquire a feature vector
3. Feature space reduction- to improve both run-time (sometimes dramatically) and segmentation accuracy. PCA is a good example of efficient feature reduction method.
4. Image pixels classification. K-means clustering is chosen du it’s relative simplicity and decent run-time.
5. Not implemented.

By running the demo the user can see various images segmentations achieved by each scheme (differing only in used feature space). Both segmentation quality and run-time are presented.

Note: the scheme is far from perfection, although it achieves decent segmentation. It can be improved in multiple ways- via parameters fitting, utilization of additional feature spaces, better classification schemes, post filtering, usage of more representative color channels etc. Moreover, due to random nature of K-means clustering, different results can be achieved for the same image and parameters. This is not a bug, but an existing scheme drawback.
