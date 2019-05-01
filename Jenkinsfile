#!groovy​
pipeline {
    options { disableConcurrentBuilds() }
    agent none
    stages {

        stage('Checkout Source') {
            agent { label 'master' }
            steps {
              deleteDir()  
              checkout scm
            }
        }

        stage('Build Elements') {
        parallel {
            stage('Build Images') {
                agent { docker { image 'geoffh1977/imagemagick:latest' } }
                steps {
                    sh 'mkdir -p image_output && convert images/cover.xcf.bz2 -flatten -resize x1000 image_output/cover.jpg'
                    stash includes: 'image_output/cover.jpg', name: 'images'
                }
            }


            stage('Build Document') {
                agent { docker { image 'geoffh1977/markdown-pp:latest' } }
                steps {
                    sh 'mkdir -p mdpp_output && markdown-pp metadata/structure.mdpp -o mdpp_output/book.md -e latexrender,youtubembed'
                    stash includes: 'mdpp_output/book.md', name: 'document'
                }
            }   
        }
        }

        stage('Create Epub Book') {
            agent { docker { image 'geoffh1977/pandoc:latest' } }
            steps {
                unstash 'images'
                unstash 'document'
                sh 'mkdir pandoc_output && pandoc -f markdown+smart -t epub3 -o pandoc_output/book.epub --toc --toc-depth=1 -s --metadata-file=metadata/metadata.yml --epub-cover-image=image_output/cover.jpg --css=metadata/stylesheet.css mdpp_output/book.md'
                stash includes: 'pandoc_output/book.epub', name: 'epub'
            }
        }

        stage('Check Mobi Compliance') {
            agent { docker { image 'geoffh1977/kindlegen:latest' } }
            steps {
                unstash 'epub'
                sh 'kindlegen pandoc_output/book.epub && rm -f pandoc_output/book.mobi'
            }
        }

        stage('Archive Artifacts') {
            agent { label 'master' }
            steps {
                unstash 'epub'
                archiveArtifacts artifacts: 'pandoc_output/book.epub'
            }
        }

    }
}

