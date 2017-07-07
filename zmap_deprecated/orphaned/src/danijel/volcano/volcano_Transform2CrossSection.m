function [mXSVolcanoes] = volcano_Transform2CrossSection(mVolcanoes, fWidth, fLength, fLat1, fLon1, fLat2, fLon2)

vSel = (mVolcanoes(:,3) == 1);
mType1 = mVolcanoes(vSel,:);

vSel = (mVolcanoes(:,3) == 2);
mType2 = mVolcanoes(vSel,:);

[vType1X, vType1Y] = lc_xsec2(mType1(:,2)', mType1(:,1)', mType1(:,1)*0, fWidth, fLength, fLat1, fLon1, fLat2, fLon2);

mType1 = [vType1X' vType1Y];
mType1(:,3) = 1;

[vType2X, vType2Y] = lc_xsec2(mType2(:,2)', mType2(:,1)', mType2(:,1)*0, fWidth, fLength, fLat1, fLon1, fLat2, fLon2);

mType2 = [vType2X' vType2Y];
mType2(:,3) = 2;

mXSVolcanoes = [mType1; mType2];

