server = function(input, output) {
  
  output$DrugBarplot <- renderPlotly({
    dfsum<-get_hist_data(input$drug)
    p1<-plot_ly(data=dfsum, x=~drug, y=~n, type='bar') ## why not 'hist' here?
  })
  
  
  
  
  output$drugVsClin<- renderPlotly({ 
    d1<-create_d1(dr=input$drug)
    bottom<-d1[d1$inhibitor <= quantile(d1$inhibitor,prob=input$n/100),]
    top<-d1[d1$inhibitor >= quantile(d1$inhibitor,prob=1-input$n/100),]
    both<-rbind(top, bottom)
    p2<-plot_ly(data = d1, x=~eval(as.name(paste(input$trait))), y=~inhibitor,
                text=paste0('Patient ID: ', d1$labId), type='scatter', mode='markers',
                hoverinfo='text+x+y',
                marker = list(size = 10,
                              color = 'rgba(255, 182, 193, .9)',
                              line = list(color = 'rgba(152, 0, 0, .8)',
                                          width = 2))) %>%
      add_trace(data = both, x=~eval(as.name(paste(input$trait))), y=~inhibitor,
                type='scatter', mode='markers', text=paste0('Patient ID: ', both$labId),
                hoverinfo='text+x+y',
                opacity = 1,
                marker = list(size = 10,
                              color = 'rgba(255, 182, 193, .9)',
                              line = list(color = 'rgba(152, 0, 0, .8)',
                                          width = 5)),showlegend=F)  %>%
      layout(title = 'Clinical Data vs. Inhibitor Data',
             yaxis = list(title="IC50",zeroline = FALSE, type = "log"),
             xaxis = list(title=paste0("Inhibitor Results by ",input$trait,", n=" , nrow(d1)),zeroline = FALSE))})
  
  
  
  
  output$drugvsExpr<- renderPlotly({ 
    d1<-create_Expression(dr=input$drug, gene=input$gene)

    bottom<-d1[d1$inhibitor <= quantile(d1$inhibitor,prob=input$n/100),]
    top<-d1[d1$inhibitor >= quantile(d1$inhibitor,prob=1-input$n/100),]
    both<-rbind(top, bottom)

    p3<-plot_ly(data = d1, x=~eval(as.name(paste(input$trait))), y=~Expression, 
                text=paste0('Patient ID: ', d1$labId), 
                type='scatter', mode='markers',
                hoverinfo='text+x+y',
                opacity = 1,
                marker = list(size = 10,
                              color = 'rgba(255, 182, 193, .9)',
                              line = list(color = 'rgba(152, 0, 0, .8)',
                                          width = 2)),showlegend=F)  %>%
      add_trace(data = both, x=~eval(as.name(paste(input$trait))), y=~Expression,
                type='scatter', mode='markers', text=paste0('Patient ID: ', both$labId),
                hoverinfo='text+x+y',
                opacity = 1,
                marker = list(size = 10,
                              color = 'rgba(255, 182, 193, .9)',
                              line = list(color = 'rgba(152, 0, 0, .8)',
                                          width = 5)),showlegend=F)  %>%
      layout(title = 'Clinical Data vs. Expression Data',
             yaxis = list(title="Gene Expression",zeroline = FALSE),
             xaxis = list(title=paste0("Expression Results of ",input$gene,
                                       ", by ",input$trait,", n in selection=" , 
                                       sum(!is.na(d1$Expression))),
                          zeroline = FALSE)
           )
  })
  
  
  
  
  output$volcano<- renderPlotly({
    results<-create_volcano()
    plot_ly(data = results, x=~foldchange, y=~1-log10(pv), 
            text=paste0('Drug: ', rownames(results)), 
            type='box', pointpos = 0, boxpoints = "all",
            hoverinfo='text+x+y',
            opacity = 1,
            marker = list(size = 10,
                          color = 'rgba(255, 182, 193, .9)',
                          line = list(color = 'rgba(152, 0, 0, .8)',
                                      width = 2)),showlegend=F)
  })
  output$WES<-renderPlotly({
    drug_WES<-create_WES(gene=input$gene, dr=input$drug)
    plot_ly(data = drug_WES, x=~Variant_Classification, y=~eval(as.name(paste(input$drug))), 
            text=paste0('Patient ID: ', drug_WES$AML_Original_LabID), 
            type='box', pointpos = 0, boxpoints = "all", jitter=0.5,
            hoverinfo='text+x+y',
            opacity = 1,
            marker = list(size = 10,
                          color = 'rgba(255, 182, 193, .9)',
                          line = list(color = 'rgba(152, 0, 0, .8)',
                                      width = 2)),showlegend=F)%>%
     
      layout(title = paste0("mutations vs. IC50"), width = 500, height = 500,
             yaxis = list(title="IC50",zeroline = FALSE),
             xaxis = list(title=paste0("Mutation type, n in selection=" , nrow(drug_WES)),zeroline = FALSE))
    
  })
   }