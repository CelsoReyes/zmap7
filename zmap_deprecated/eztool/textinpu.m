function textinpu()
    %
    str=get(gco,'String');
    p=get(gca,'Currentpoint');
    text(p(1,1),p(1,2),str);
