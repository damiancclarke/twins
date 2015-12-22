# worldTwin.R                    damiancclarke             yyyy-mm-dd:2015-12-19
#---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
#
# Visualise results from twin regressions.
#
# HEALTH (+): Height (US), Height (Sweden), Height (DHS),
# HEALTH (-): Diabetes (US), Hypertension (US), Diabetes (Sw), Hypertension (Sw)
#             Anemia (DHS), Low weight (Chile), Obese (Chile), Diabetes (Chile),
#             Depression (Chile)
# HEALTH RELATED BEHAVIOURS (+): Health Food (UK), Fruit (UK), Care*2 (DHS)
# HEALTH RELATED BEHAVIOURS (-): Smoked 1, Smoked 2, Smoked 3, (US), Smoked 1,
# Smoked 3 (Sweden), Smoked (Chile), Drugs (Chile), Alcohol (Chile), No care
# (DHS)
#
# PREGNANCY HEALTH (+): 
# PREGNANCY HEALTH (-): Gestation Diabetes, Eclampsia, 


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
               "Child","Adult","Urban","Rural","Occupational","Occupational"),
    Data  =  factor(c("USA  ","USA  ","USA  ","Chile  ","Chile  ","UK  ","UK  ",
                      "UK  ","UK  ","DHS  ","DHS  ","DHS  ","Sweden  ","Sweden  "))
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
    Data  = factor(c("USA","USA","USA","Chile","Chile","UK","UK","UK","UK",
                     "DHS","DHS","DHS"))
)
test2$x <- reorder(test2$x, c(12,11,10,9,8,7,6,5,4,3,2,1))

test3 <- data.frame(
    x      = c("one","two","three","four","five","six","seven","eight"),
    y      = c(-4.0,-4.4,-7.1,-8.2,-2.9,-3.0,-4.0,-9.0),
    yhi    = c(-6.0,-4.8,-7.6,-8.4,-3.3,-3.1,-4.8,-10.0),
    ylo    = c(-2.0,-4.2,-6.6,-8.0,-2.5,-2.9,-3.2,-8.0),
    lab    = c("total","Year1","Year2","Year3","Year4","Male","Female","Infant"),
    Data  = factor(c("USA","USA","USA","Chile","Chile","UK","UK","UK"))
)
test3$x <- reorder(test3$x, c(8,7,6,5,4,3,2,1))

testA <- data.frame(
    x      = c("one","two","three","four","five","six","seven","eight","nine",
               "ten","eleven","twelve","thirteen","fourteen","fifteen","sixteen",
               "seventeen","eighteen","nineteen","twenty","twentyone","twentytwo",
               "twentythree"),
    y      = c(NA,-2,-2,-2,-2,-2,-2,-2,-2,-2,NA,-2,-2,-2,-2,-2,-2,-2,-2,-2,NA,-2,-2),
    yhi    = c(NA,-1,-1,-1,-1,-1,-1,-1,-1,-1,NA,-1,-1,-1,-1,-1,-1,-1,-1,-1,NA,-1,-1),
    ylo    = c(NA,-3,-3,-3,-3,-3,-3,-3,-3,-3,NA,-3,-3,-3,-3,-3,-3,-3,-3,-3,NA,-3,-3),
    labpos = c(NA,17,17,17,17,17,17,17,17,17,NA,17,17,17,17,17,17,17,17,17,NA,17,17),
    lab    = c("HEALTH STOCKS","Diabetes","Hypertension","Diabetes","Hypertension",
               "Anemia","Low Weight","Obese","Diabetes","Depression",
               "HEALTH BEHAVIOURS","Smoked (T1)","Smoked (T2)","Smoked (T3)",
               "Smoked (T1)","Smoked (T3)","Smoked (T1)","Drugs","Alcohol",
               "No Care","PREGNANCY HEALTH","Diabetes (gest)","Eclampsia"),
    Data  =  factor(c(NA,"U.S.A.  ","U.S.A.  ","Sweden  ","Sweden  ","DHS  ","Chile  ",
                      "Chile  ","Chile  ","Chile  ",NA,"U.S.A.  ","U.S.A.  ","U.S.A.  ",
                      "Sweden  ","Sweden  ","Chile  ","Chile  ","Chile  ","DHS  ",NA,
                      "U.S.A.  ","U.S.A.  "))
)
testA$x <- reorder(testA$x, c(23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1))

testB <- data.frame(
    x      = c("one","two","three","four","five","six","seven","eight","nine"),
    y      = c(NA,2 ,2 ,2 ,NA,2 ,2 ,2 ,2 ),
    yhi    = c(NA,3 ,3 ,3 ,NA,3 ,3 ,3 ,3 ),
    ylo    = c(NA,1 ,1 ,1 ,NA,1 ,1 ,1 ,1 ),
    labpos = c(NA,17,17,17,NA,17,17,17,17),
    lab    = c("HEALTH STOCKS","Height","Height","Height",
               "HEALTH BEHAVIOURS","Health Food","Fruit","Doctor Available",
               "Nurse Available"),
    Data  =  factor(c(NA,"U.S.A.  ","Sweden  ","DHS  ",NA,"U.K.  ","U.K.  ",
                      "DHS  ","DHS  "))
)
testB$x <- reorder(testB$x, c(9,8,7,6,5,4,3,2,1))

#-------------------------------------------------------------------------------
#--- (2) Make one version of the plot
#-------------------------------------------------------------------------------
a <- ggplot(test1, aes(x=x, y=y, ymin=ylo, ymax=yhi, colour=Data))             +
     geom_pointrange(shape=15, size=1.2, position=position_dodge(width=c(0.1)))+
     coord_flip() + geom_hline(aes(x=0), lty=2) + xlab('Variable')             +
     scale_x_discrete(breaks=test1$x,labels=test1$lab)                         +
     scale_y_continuous(limits = c(-1,18)) + theme_bw()                        +
     ylab(expression(paste("Effect Size (", sigma, ")"))) + xlab("")           +
     ggtitle("Health") + theme(legend.position="bottom")

c <- ggplot(test1, aes(x=x, y=y, ymin=ylo, ymax=yhi, colour=Data))             +
     geom_pointrange(shape=15, size=1.2, position=position_dodge(width=c(0.1)))+
     coord_flip() + geom_hline(aes(x=0), lty=2) + xlab('Variable')             +
     scale_x_discrete(breaks=test1$x,labels=test1$lab)                         +
     scale_y_continuous(limits = c(-1,18)) + theme_bw()                        +
     ylab(expression(paste("Effect Size (", sigma, ")"))) + xlab("")           +
     ggtitle("Health Related Behaviours") + theme(legend.position="none")

b <- ggplot(test2, aes(x=x, y=y, ymin=ylo, ymax=yhi, colour=Data))             +
     geom_pointrange(shape=15, size=1.2, position=position_dodge(width=c(0.1)))+
     coord_flip() + geom_hline(aes(x=0), lty=2) + xlab('Variable')             +
     scale_x_discrete(breaks=test2$x,labels=test2$lab)                         +
     scale_y_continuous(limits = c(-18,1)) + theme_bw()                        +
     ylab(expression(paste("Effect Size (", sigma, ")"))) + xlab("")           +
     ggtitle("Health") + theme(legend.position="none")

d <- ggplot(test3, aes(x=x, y=y, ymin=ylo, ymax=yhi, colour=Data))             +
     geom_pointrange(shape=15, size=1.2, position=position_dodge(width=c(0.1)))+
     coord_flip() + geom_hline(aes(x=0), lty=2) + xlab('Variable')             +
     scale_x_discrete(breaks=test3$x,labels=test3$lab)                         +
     scale_y_continuous(limits = c(-18,1)) + theme_bw()                        +
     ylab(expression(paste("Effect Size (", sigma, ")"))) + xlab("")           +
     ggtitle("Health Related Behaviours") + theme(legend.position="none")

e <- ggplot(testA, aes(x=x, y=y, ymin=ylo, ymax=yhi, colour=Data))             +
     geom_pointrange(shape=15, size=1.2, position=position_dodge(width=c(0.1)))+
     coord_flip() + geom_hline(aes(x=0), lty=2) + xlab('Variable')             +
     scale_x_discrete(breaks=testA$x,labels=testA$lab)                         +
     scale_y_continuous(limits = c(-5,1)) + theme_bw()                        +
     ylab(expression(paste("Effect Size (", sigma, ")"))) + xlab("")           +
     ggtitle("Negative Health Measures") + theme(legend.position="none")

f <- ggplot(testB, aes(x=x, y=y, ymin=ylo, ymax=yhi, colour=Data))             +
     geom_pointrange(shape=15, size=1.2, position=position_dodge(width=c(0.1)))+
     coord_flip() + geom_hline(aes(x=0), lty=2) + xlab('Variable')             +
     scale_x_discrete(breaks=testB$x,labels=testB$lab)                         +
     scale_y_continuous(limits = c(-1,5)) + theme_bw()                        +
     ylab(expression(paste("Effect Size (", sigma, ")"))) + xlab("")           +
     ggtitle("Positive Health Measures") + theme(legend.position="none")


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
grid.arrange(arrangeGrob(b + theme(legend.position="none"),
                         a + theme(legend.position="none"),
                         d + theme(legend.position="none"),
                         c + theme(legend.position="none"),
                         nrow=2),
             mylegend, nrow=2,heights=c(10, 1))
dev.off()

pdf("../paper/twinsHealth/tex/twinsEffects_two.pdf", width = 8, height = 12)
grid.arrange(arrangeGrob(e + theme(legend.position="none"),
                         f + theme(legend.position="none"),
                         nrow=2,heights=c(23,9)),
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
