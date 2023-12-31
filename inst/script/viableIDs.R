## Overall strategy process the data in NCBI.sqlite and extract
## meaningful taxIDs.  Then save those for use in the recipe above.

## Step 0: Run these functions from a directory where you have already
## built an NCBI.sqlite file. You may call the example in
## makeOrgPackageFromNCBI()

## You can run on an EC2 instance or locally
## If you run locally you will need at least 59G of space as of May 2021
## the size of the files tends to increase slightly each release

if(FALSE){
    library(AnnotationForge)
    options(timeout=10000000000)
    makeOrgPackageFromNCBI(version = "0.1",author = "Some One <so@someplace.org>",
                           maintainer = "Some One <so@someplace.org>",
                           outputDir = ".",
                           tax_id = "59729",
                           genus = "Taeniopygia",
                           species = "guttata")
}

## STEP 1:
## This helper will just get the taxIDs that we already have GO data for.
.getCoreTaxIds <- function(NCBIFilesDir=getwd()){
    ## connect to the DB
    require(RSQLite)
    NCBIcon <- dbConnect(SQLite(), dbname = "NCBI.sqlite")
    res = dbGetQuery(NCBIcon, "SELECT DISTINCT tax_id FROM gene2go;")[[1]]
    dbDisconnect(NCBIcon)
    res
}
coreIDs = .getCoreTaxIds()

## Next get the list of other taxIds where there is at least one GO term
## Step 2:
.getAltTaxIds <- function(NCBIFilesDir=getwd()){
    require(RSQLite)
    NCBIcon <- dbConnect(SQLite(), dbname = "NCBI.sqlite")
    ## Then get the go related Tax Ids
    sql <- paste0("SELECT distinct NCBItaxon FROM altGO")
    goTaxIds <- dbGetQuery(NCBIcon, sql)[[1]]
    ## And also the gene related tax Ids
    sql <- paste0("SELECT distinct tax_id FROM gene_info")
    geneTaxIds <- dbGetQuery(NCBIcon, sql)[[1]]
    tbl = intersect(goTaxIds, geneTaxIds)
    dbDisconnect(NCBIcon)
    tbl
}

altTaxIDs = .getAltTaxIds()

## Step 3: combine all taxIds and remove ones that we already
## have as packages:
.getPackageOrgDbTaxIds <- function(){
#    orgDbs <- .GetOrgDbs()
# if orgDbs are not downloaded yet, do .getOrgDbs(TRUE)
    orgDbs <-AnnotationHubData:::.getOrgDbs(TRUE)
#    as.integer(unlist(lapply(orgDbs,
#                function(x){m <- metadata(x); m[m$name=='TAXID', 2] })))
    as.integer(AnnotationHubData:::.orgDbPkgMetadataFromObjs(orgDbs,
                                                             "3.17")$taxonomyId)

}

existingOrgPkgTaxIds <- .getPackageOrgDbTaxIds()
allIds <- union(coreIDs, altTaxIDs)
allIds <- allIds[!(allIds %in% existingOrgPkgTaxIds)]

## Step 4: sort the taxIds by the coverage for genes
.getSortedTaxIds <- function(allIds, NCBIFilesDir=getwd()){

    NCBIcon <- dbConnect(SQLite(), dbname = "NCBI.sqlite")
    ## ## Then get the go related Tax Ids
    idStr <- paste(allIds,collapse="','")
    sql <- paste0("SELECT tax_id FROM gene_info WHERE tax_id IN('",idStr,"')")
    giFullTaxIds <- dbGetQuery(NCBIcon, sql)[[1]]

    ## now I just need to quantify the number of each type
    taxidTable <- table(giFullTaxIds)
    tbl = names(sort(taxidTable, decreasing=TRUE))[1:1000]
    dbDisconnect(NCBIcon)
    tbl
}

results <- .getSortedTaxIds(allIds)
save(results, file='viableIDs.rda')

## NCBIcon <- dbConnect(SQLite(), dbname = "NCBI.sqlite")
## ## Then get the go related Tax Ids
## idStr <- paste(allIds,collapse="','")
## sql <- paste0("SELECT tax_id FROM gene_info WHERE tax_id IN('",idStr,"')")
## giFullTaxIds <- dbGetQuery(NCBIcon, sql)[[1]]
##
## ## now I just need to quantify the number of each type
## taxidTable <- table(giFullTaxIds)
## head(sort(taxidTable, decreasing=TRUE))
## The length of the allTaxIDs vector is: 555345!
## Match the existing tax IDs with a third function:
