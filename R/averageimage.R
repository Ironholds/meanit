#'@title averageimage
#'@description Create a composite image from a list of PNGs or JPEGs
#'@details averageimage generates composite PNGs or JPEGs. To deal with images of different sizes, the smallest dimensions of listed images are calculated, and
#'each image is then trimmed to match those dimensions. This trimming operates from the middle of the image,
#'rather than any edge, in order to prioritise retaining the 'important' bits.
#'
#'@section Caveats and errors: Averageimage accepts both PNGs (greyscale or full) and JPEGs, although the list of
#'files or URLs provided should only refer to one type of image. If JPEGs and PNGs are combined, it won't
#'work - if full and grayscale PNGs are provided, the returned image will be grayscale.
#'
#'For retrieving images from URLs, the package (and function) is dependent on RCurl. This means,
#'amongst other things, that https is not a supported protocol. URLs must be provided with http.
#'@param input any one of a vector of URLs, a vector of absolute file names, or a list of
#'already-read PNGs or JPEGs.
#'@param save.file the absolute file name to save the composite image into
#'
#'@examples
#'#Running from URLs and returning the composite image as an array
#'composite_image <- averageimage(input = c("https://upload.wikimedia.org/wikipedia/commons/e/e0/Mt_Basin_and_Mt_Tom_shot_from_the_South.JPG",
#'                                          "https://upload.wikimedia.org/wikipedia/commons/c/c3/Mt_Basin_and_Mt_Tom_shot_from_the_East.JPG"))
#'str(composite_image)
#'#num [1:1224, 1:1632, 1:3] 0.416 0.418 0.416 0.414 0.416 ...
#'
#'#Running from files and saving to file
#'\dontrun{
#'averageimage(input = c("first_image.png","second_image.png"), save.file = "output.png")
#'>TRUE
#'}
#'@export 
averageimage <- function(input, save.file = NULL){
  
  #If URLs are provided instead of files...
  if(length(grep(x = input[[1]], pattern = "http", ignore.case = TRUE)) > 0 ){
    
    #Check type and retrieve relevant function
    image_handler <- type_checker(x = input)

    #Run retrieve_from_url with relevant handler
    images <- lapply(input, retrieve_from_url, image_handler$reader)
  
  } else if(class(input[[1]]) == "array"){
    
    #If it's already read in, work out the handlers from save.file
    #Then simply use the input as the images
    image_handler <- type_checker(x = save.file)
    images <- input
    
  } else { 
    
    #Otherwise, check and retrieve from file with relevant handler
    image_handler <- type_checker(x = input)
    images <- lapply(input, retrieve_from_file, image_handler$reader)
    
  }
  
  #Work out dims and subsection image
  normalised_images <- normalsizer(images)
  
  #Compose
  composite <- image_composer(normalised_images)
  
  #If save.file = NULL, simply return the composite image as an array
  if(is.null(save.file)){
    
    return(composite)
    
  }
  
  #Otherwise, save and return TRUE
  image_handler$writer(image = composite, target = save.file)
  return(TRUE)
}