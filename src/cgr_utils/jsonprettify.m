function results = jsonprettify(txt)
    % JSONPRETTIFY makes json output pretty
    nIndent=3;
    inQuote = rem(cumsum(txt=='"'),2);
    notopenBrace= inQuote & txt == '{';
    notcloseBrace= inQuote & txt == '}';
    notcommas = inQuote & txt == ',';
    txt(notcommas)=char(1);
    txt(notopenBrace)=char(2);
    txt(notcloseBrace)=char(3);
    results = strrep(txt,',',[',' newline]);
    results = strrep(results,char(1),','); %put commas back
    results = strrep(results,'{',['{' newline]);
    results = strrep(results,'}',[newline '}']);
    results = strrep(results,char(2),'{');
    results = strrep(results,char(3),'}');
    inQuote = rem(cumsum(results=='"'),2);
    nBraces = cumsum(~inQuote&results=='{') - cumsum(~inQuote&results=='}');
    splits = find(results==newline);
    for i=numel(splits):-1:1
        x = splits(i);
        if results(x+1)=='}'
            spacer=repmat(' ',1,nIndent .* nBraces(x) - nIndent);
        else
            spacer=repmat(' ',1,nIndent .* nBraces(x));
        end
        results=[results(1:x), spacer, results(x+1:end)];
    end
    
    
end