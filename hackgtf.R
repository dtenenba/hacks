library(AnnotationHubServer)
library(AnnotationHubData)
preparerInstance <- do.call("EnsemblGtfImportPreparer", list())
if (!exists("allmd"))
    allmd <- newResources(preparerInstance, list())

.printf <- function(...) print(noquote(sprintf(...)))

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
      print(metadata(md)$SourceUrl)
      destfile = file.path(ahroot, metadata(md)$RDataPath)
      if (file.exists(destfile))
      {
          .printf("file %s exists, skipping", destfile)
          next
      }
      recipe <- AnnotationHubRecipe(md)
      tryCatch(run(recipe), error=function(e){
        warning(sprintf("ERROR: %s, %s", metadata(md)$SourceUrl,
                conditionMessage(e)))  
      })
    }
  }
  gtfmd
}