# worldTwin.R                    damiancclarke             yyyy-mm-dd:2015-12-19
#---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
#
# Visualise results from twin regressions.
#
#
#
#
#


library(ggplot2)
library(gridExtra)

#-------------------------------------------------------------------------------
#--- (1) Import results from file
#-------------------------------------------------------------------------------
test1 <- data.frame(
    x      = c("one","two","three","four","five","six","seven","eight","nine",
               "ten","eleven","twelve","thirteen","fourteen"),
    y      = c(4.0,4.4,7.1,8.2,2.9,3.0,4.0,9.0,11.0,7.6,4.4,4.6,4.9,5.0),
    yhi    = c(6.0,4.8,7.6,8.4,3.3,3.1,4.8,10.0,16.0,8.0,4.5,5.0,6.9,5.7),
    ylo    = c(2.0,4.2,6.6,8.0,2.5,2.9,3.2,8.0,6.0,7.2,4.3,4.2,2.9,4.3),
    labpos = c(17,17,17,17,17,17,17,17,17,17,17,17,17,17),
    lab    = c("total","Year1","Year2","Year3","Year4","Male","Female","Infant",
               "Child","Adult","Urban","Rural","Occupational","Non-Occupational"),
    Data  = factor(c(1,2,2,2,2,3,3,4,4,4,5,5,6,6))
)
test1$x <- reorder(test1$x, c(14,13,12,11,10,9,8,7,6,5,4,3,2,1))

test2 <- data.frame(
    x      = c("one","two","three","four","five","six","seven","eight","nine",
               "ten","eleven","twelve"),
    y      = c(-4.0,-4.4,-7.1,-8.2,-2.9,-3.0,-4.0,-9.0,-11.0,-7.6,-4.4,-4.6),
    yhi    = c(-6.0,-4.8,-7.6,-8.4,-3.3,-3.1,-4.8,-10.0,-16.0,-8.0,-4.5,-5.0),
    ylo    = c(-2.0,-4.2,-6.6,-8.0,-2.5,-2.9,-3.2,-8.0,-6.0,-7.2,-4.3,-4.2),
    lab    = c("total","Year1","Year2","Year3","Year4","Male","Female","Infant",
               "Child","Adult","Urban","Rural"),
    Data  = factor(c(1,2,2,2,2,3,3,4,4,4,5,5))
)
test2$x <- reorder(test2$x, c(12,11,10,9,8,7,6,5,4,3,2,1))

#-------------------------------------------------------------------------------
#--- (2) Make one version of the plot
#-------------------------------------------------------------------------------
a <- ggplot(test1, aes(x=x, y=y, ymin=ylo, ymax=yhi, colour=Data))             +
     geom_pointrange(shape=15, size=1.2, position=position_dodge(width=c(0.1)))+
     coord_flip() + geom_hline(aes(x=0), lty=2) + xlab('Variable')             +
     scale_x_discrete(breaks=test1$x,labels=test1$lab)                         +
     scale_y_continuous(limits = c(-1,18)) + theme_bw()                        +
     ylab("Blood lead level (ug/dL)") + xlab("")                               +
     ggtitle("Health") + theme(legend.position="bottom")

c <- ggplot(test1, aes(x=x, y=y, ymin=ylo, ymax=yhi, colour=Data))             +
     geom_pointrange(shape=15, size=1.2, position=position_dodge(width=c(0.1)))+
     coord_flip() + geom_hline(aes(x=0), lty=2) + xlab('Variable')             +
     scale_x_discrete(breaks=test1$x,labels=test1$lab)                         +
     scale_y_continuous(limits = c(-1,18)) + theme_bw()                        +
     ylab("Blood lead level (ug/dL)") + xlab("")                               +
     ggtitle("Health Related Behaviours") + theme(legend.position="none")

e <- ggplot(test1, aes(x=x, y=y, ymin=ylo, ymax=yhi, colour=Data))             +
     geom_pointrange(shape=15, size=1.2, position=position_dodge(width=c(0.1)))+
     coord_flip() + geom_hline(aes(x=0), lty=2) + xlab('Variable')             +
     scale_x_discrete(breaks=test1$x,labels=test1$lab)                         +
     scale_y_continuous(limits = c(-1,18)) + theme_bw()                        +
     ylab("Blood lead level (ug/dL)") + xlab("")                               +
     ggtitle("Pregnancy Related Health") + theme(legend.position="none")

b <- ggplot(test2, aes(x=x, y=y, ymin=ylo, ymax=yhi, colour=Data))             +
     geom_pointrange(shape=15, size=1.2, position=position_dodge(width=c(0.1)))+
     coord_flip() + geom_hline(aes(x=0), lty=2) + xlab('Variable')             +
     scale_x_discrete(breaks=test2$x,labels=test2$lab)                         +
     scale_y_continuous(limits = c(-18,1)) + theme_bw()                        +
     ylab("Blood lead level (ug/dL)") + xlab("")                               +
     ggtitle("Health") + theme(legend.position="none")

d <- ggplot(test2, aes(x=x, y=y, ymin=ylo, ymax=yhi, colour=Data))             +
     geom_pointrange(shape=15, size=1.2, position=position_dodge(width=c(0.1)))+
     coord_flip() + geom_hline(aes(x=0), lty=2) + xlab('Variable')             +
     scale_x_discrete(breaks=test2$x,labels=test2$lab)                         +
     scale_y_continuous(limits = c(-18,1)) + theme_bw()                        +
     ylab("Blood lead level (ug/dL)") + xlab("")                               +
     ggtitle("Health Related Behaviours") + theme(legend.position="none")

f <- ggplot(test2, aes(x=x, y=y, ymin=ylo, ymax=yhi, colour=Data))             +
     geom_pointrange(shape=15, size=1.2, position=position_dodge(width=c(0.1)))+
     coord_flip() + geom_hline(aes(x=0), lty=2) + xlab('Variable')             +
     scale_x_discrete(breaks=test2$x,labels=test2$lab)                         +
     scale_y_continuous(limits = c(-18,1)) + theme_bw()                        +
     ylab("Blood lead level (ug/dL)") + xlab("")                               +
     ggtitle("Pregnancy Related Health") + theme(legend.position="none")




# ADD LABELS FOR EACH POINT/CI
#a + geom_text(data=test1, aes(x = x, y = labpos, label = lab, hjust=0)) 

#-------------------------------------------------------------------------------
#--- (3) Plot
#-------------------------------------------------------------------------------
g_legend<-function(a.gplot){
      tmp <- ggplot_gtable(ggplot_build(a.gplot))
        leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
        legend <- tmp$grobs[[leg]]
        return(legend)}

mylegend<-g_legend(a)

pdf("../paper/twinsHealth/tex/twinsEffects.pdf", width = 8, height = 12)
grid.arrange(arrangeGrob(a + theme(legend.position="none"),
                             b + theme(legend.position="none"),
                             c + theme(legend.position="none"),
                             d + theme(legend.position="none"),
                             e + theme(legend.position="none"),
                             f + theme(legend.position="none"),
                                                       nrow=3),
                             mylegend, nrow=2,heights=c(10, 1))
dev.off()


### 1.       Health (height BMI anemia)
###
### 2.       Heath-related behaviours (smoking, drugs, prenatal care) ;;;
###          we must explain that prenatal care is
###          an index of availability (cluster level average)
###
### 3.       Pregnancy related health (eclampsia hypertension etc)
###
###
