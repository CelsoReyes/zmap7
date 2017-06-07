function gmt_master(sOutput)

hAxes = gca;

gmt_init(hAxes, sOutput);

vKids = get(hAxes, 'Children');

for nCnt = length(vKids):-1:1
  sType = lower(get(vKids(nCnt), 'Type'));
  switch sType
  case 'surface'
    gmt_pcolor(vKids(nCnt), sOutput, num2str(nCnt));
  case 'line'
    gmt_xy(vKids(nCnt), sOutput, num2str(nCnt));
  end
end

gmt_done(sOutput);
