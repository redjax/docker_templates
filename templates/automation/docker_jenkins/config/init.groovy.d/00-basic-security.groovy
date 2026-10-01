import jenkins.model.*
import hudson.security.*

def j = Jenkins.get()

if (j.getNumExecutors() != 0) {
    j.setNumExecutors(0)
    j.save()
}