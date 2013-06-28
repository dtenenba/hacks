.printf <- function(...) print(noquote(sprintf(...)))


library(AnnotationHubServer)
library(AnnotationHubData)
preparerInstance <- do.call("EnsemblFastaImportPreparer", list())
if (!exists("allmd"))
    allmd <- newResources(preparerInstance, list())


hackfasta <- function(ahroot=file.path(Sys.getenv("HOME"), "ahroot2"),
  rootdir=file.path(ahroot, "ensembl"))
{
    all <- list()
    sourceurls <- unlist(lapply(allmd, function(x){
        md <- metadata(x)
        md$SourceUrl
        }))
    fastafiles <- dir(rootdir, recursive=TRUE, pattern="fa.gz$")
    print(fastafiles)
    for (fastafile in fastafiles)
    {
        .printf("processing %s.", fastafile)
        pat <- paste(fastafile, "$", sep="")
        #gzpat <- sub(".rz$", ".gz", fastafile)
        #gzpat <- paste(gzpat, "$", sep="")
        #print(gzpat)
        if (any(grepl(pat, sourceurls)))
        {
            
            md <- allmd[[which(grepl(pat, sourceurls))]]
            allmd <- append(all, md)
            metadata(md)$AnnotationHubRoot <- ahroot
            rz <- sub(".gz$", ".rz", metadata(md)$RDataPath)
            metadata(md)$RDataPath <- rz
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
    all
}