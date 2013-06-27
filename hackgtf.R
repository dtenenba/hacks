library(AnnotationHubServer)
library(AnnotationHubData)
preparerInstance <- do.call("EnsemblGtfImportPreparer", list())
allmd <- newResources(preparerInstance, list())


hackgtf <- function(ahroot=file.path(Sys.getenv("HOME"), "ahroot2"),
                      rootdir=file.path(ahroot, "ensembl"))
{
  gtfmd <- list()
  sourceurls <- unlist(lapply(allmd, function(x){
    md <- metadata(x)
    md$SourceUrl
  }))
  gtffiles <- dir(rootdir, recursive=TRUE, pattern=".gtf.gz$")
  print(gtffiles)
  for (gtffile in gtffiles)
  {
    pat <- paste(gtffile, "$", sep="")
    if (any(grepl(pat, sourceurls)))
    {
      md <- allmd[[which(grepl(pat, sourceurls))]]
      gtfmd <- append(gtfmd, md)
      metadata(md)$AnnotationHubRoot <- ahroot
      print("hi")
      recipe <- AnnotationHubRecipe(md)
      run(recipe)
    }
  }
  gtfmd
}