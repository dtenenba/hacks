#library(AnnotationHubServer)
#library(AnnotationHubData)
#preparerInstance <- do.call("EnsemblFastaImportPreparer", list())
#allmd <- newResources(preparerInstance, list())


hackfasta <- function(ahroot=file.path(Sys.getenv("HOME"), "ahroot2"),
  rootdir=file.path(ahroot, "ensembl"))
{
    sourceurls <- unlist(lapply(allmd, function(x){
        md <- metadata(x)
        md$SourceUrl
        }))
    fastafiles <- dir(rootdir, recursive=TRUE, pattern="fa.gz$")
    print(fastafiles)
    for (fastafile in fastafiles)
    {
        pat <- paste(fastafile, "$", sep="")
        #gzpat <- sub(".rz$", ".gz", fastafile)
        #gzpat <- paste(gzpat, "$", sep="")
        #print(gzpat)
        if (any(grepl(pat, sourceurls)))
        {
            md <- allmd[[which(grepl(pat, sourceurls))]]
            metadata(md)$AnnotationHubRoot <- ahroot
            rz <- sub(".gz$", ".rz", metadata(md)$RDataPath)
            metadata(md)$RDataPath <- rz
            print(metadata(md)$SourceUrl)
            recipe <- AnnotationHubRecipe(md)
            browser()
            run(recipe)
        }
    }
}