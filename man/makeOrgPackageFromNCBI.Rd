\name{makeOrgPackageFromNCBI}

\alias{makeOrgPackageFromNCBI}


\title{
  Make an organism package from annotations available from NCBI.
}
\description{
  The \code{makeOrgPackageFromNCBI} function allows the user to make an
  organism package from NCBI annotations available from the NCBI.
}
\usage{

  makeOrgPackageFromNCBI(
    version=,
    maintainer,
    author,
    outputDir=getwd(),
    tax_id,
    genus=NULL,
    species=NULL,
    NCBIFilesDir=getwd(),
    databaseOnly=FALSE,
    useDeprecatedStyle=FALSE,
    rebuildCache=TRUE,
    verbose=TRUE,
    ensemblVersion=NULL)
}

\arguments{
  \item{version}{
    Package version in 'x.y.z' format.
  }
  \item{maintainer}{
    Package maintainer followed by email
  }
  \item{author}{
    Creator of package.
  }
  \item{outputDir}{
    Path where the package source should be assembled.
  }
  \item{tax_id}{
    The Taxonomy ID that represents the organism.
  }
  \item{genus}{
    Single string indicating the genus.
  }
  \item{species}{
    Single string indicating the species.
  }
  \item{NCBIFilesDir}{
    When a path is given, the files used to create the DB are saved locally.
  }
  \item{databaseOnly}{
    When TRUE, a DB is created without the package infrastructure. Used
    for OrgDb packages hosted on AnnotationHub.
  }
  \item{useDeprecatedStyle}{
    Legacy support for older package style with bimaps.
  }
  \item{rebuildCache}{
    When TRUE, the files used to create the DB are refreshed 
    (i.e., re-downloaded) if the timestamp is greater than 24 hours old. When 
    FALSE, the temporary NCBI.sqlite DB and final package are re-generated 
    from local files in \code{outputDir}. Used internally and for testing.}
  \item{verbose}{
    When TRUE, status messages are printed.
  }
  \item{ensemblVersion}{
    Ensmbl version to use. When NULL, uses the current version.
  }
}

\details{
  \code{makeOrgPackageFromNCBI} downloads multiple files and assembles a 33 GB
  database in \code{NCBIFilesDir}. The first time the function is run it may
  take well over an hour; subsequent calls reuse files from the cache and are
  much faster. The default behavior of \code{makeOrgPackageFromNCBI} attempts to 
  refresh the cached files each day (suppress with \code{rebuildCache =
    FALSE}). 

  The files that are downloaded from NCBI may take longer to download
  than the default timeout permits. We encourage users to set a
  \code{options(timeout=xxx)} to encourage the files to finish
  downloading. Adjust the timelimit according to download speed and
  capacity.

  Depending on the organism, the database file could reach up to 49 G.
  You will need ~62G free for downloading files and creating the largest
  database as of February 2022.

  Some orgDbs are already provided through \code{AnnotationHub}. See
  package \code{AnnotationHub::AnnotationHub}
}

\value{Nothing returned to the R session. Just creates an organism
annotation package.}

\author{
  M. Carlson
}

\examples{

\dontrun{
## Makes an organism package for Zebra Finch from NCBI:

makeOrgPackageFromNCBI(version = "0.1",
                       author = "Some One <so@someplace.org>",
                       maintainer = "Some One <so@someplace.org>",
                       outputDir = ".",
                       tax_id = "59729",
                       genus = "Taeniopygia",
                       species = "guttata")

}

}
