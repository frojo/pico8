pico-8 cartridge // http://www.pico-8.com
version 16
__lua__


vram=0x6000
bang=0

while(true) do
 if(btn(4, 1)) cls()
 if btnp(4) then bang=rnd(1) / 10 * 10 end
 scr=4+flr(bang*10)

 memcpy(vram+scr*64,vram,0x2000-scr*64)
 rectfill(0,0,128,scr,6)

 for i=0,7 do
  x=32+8*i
  x+=sin(time()*(0.4-i*0.0337))*48
  w=6+sin(time()*0.32+i*0.123)*4
  rectfill(x-w,0,x+w,scr,7+i)
 end

 for i=0,23 do
  for y=band(shr(i,1),1),3,2 do
   sy=32+i*4+y
   dx=rnd(20*bang)
   for x=band(i,1),127,2 do
    pset(x+dx,sy,max(pget(x,sy)-1,0))
   end
  end
 end

 flip()
 bang*=0.84
 
end
__label__
77aaaaaaaaaaaaaaaaaa88888888888ddddd886666666666666666666666666666666666666bbbbbbbbbbbb9999ccccccc99966666666666666666666666eeee
77aaaaaaaaaaaaaaaaaa88888888888ddddd886666666666666666666666666666666666666bbbbbbbbbbbb9999ccccccc99966666666666666666666666eeee
77aaaaaaaaaaaaaaaaaa88888888888ddddd886666666666666666666666666666666666666bbbbbbbbbbbb9999ccccccc99966666666666666666666666eeee
77aaaaaaaaaaaaaaaaaa88888888888ddddd886666666666666666666666666666666666666bbbbbbbbbbbb9999ccccccc99966666666666666666666666eeee
77aaaaaaaaaaaaaaaaaa88888888888ddddd886666666666666666666666666666666666666bbbbbbbbbbbb9999ccccccc99966666666666666666666666eeee
7aaaaaaaaaaaaaaaaaa666888888888ddddd88888866666666666666666666666666666666666bbbbbbbbbbbbccccccc99966666666666666666666666666eee
7aaaaaaaaaaaaaaaaaa666888888888ddddd88888866666666666666666666666666666666666bbbbbbbbbbbbccccccc99966666666666666666666666666eee
7aaaaaaaaaaaaaaaaaa666888888888ddddd88888866666666666666666666666666666666666bbbbbbbbbbbbccccccc99966666666666666666666666666eee
7aaaaaaaaaaaaaaaaaa666888888888ddddd88888866666666666666666666666666666666666bbbbbbbbbbbbccccccc99966666666666666666666666666eee
aaaaaaaaaaaaaaaaaaa6666666888888ddddd888888886666666666666666666666666666666699bbbbbbbcccccccc99996666666666666666666666666666ee
aaaaaaaaaaaaaaaaaaa6666666888888ddddd888888886666666666666666666666666666666699bbbbbbbcccccccc99996666666666666666666666666666ee
aaaaaaaaaaaaaaaaaaa6666666888888ddddd888888886666666666666666666666666666666699bbbbbbbcccccccc99996666666666666666666666666666ee
aaaaaaaaaaaaaaaaaaa6666666888888ddddd888888886666666666666666666666666666666699bbbbbbbcccccccc99996666666666666666666666666666ee
aaaaaaaaaaaaaaaaaa666666666666888ddddd8888888888866666666666666666666666666999999bbbccccccccbbb66666666666666666666666666666666e
aaaaaaaaaaaaaaaaaa666666666666888ddddd8888888888866666666666666666666666666999999bbbccccccccbbb66666666666666666666666666666666e
aaaaaaaaaaaaaaaaaa666666666666888ddddd8888888888866666666666666666666666666999999bbbccccccccbbb66666666666666666666666666666666e
aaaaaaaaaaaaaaaaaa666666666666888ddddd8888888888866666666666666666666666666999999bbbccccccccbbb66666666666666666666666666666666e
aaaaaaaaaaaaaaaaaa666666666666666dddddd888888888888866666666666666666666999999999cccccccccbbbbbbbb666666666666666666666666666666
aaaaaaaaaaaaaaaaaa666666666666666dddddd888888888888866666666666666666666999999999cccccccccbbbbbbbb666666666666666666666666666666
aaaaaaaaaaaaaaaaaa666666666666666dddddd888888888888866666666666666666666999999999cccccccccbbbbbbbb666666666666666666666666666666
aaaaaaaaaaaaaaaaaa666666666666666dddddd888888888888866666666666666666666999999999cccccccccbbbbbbbb666666666666666666666666666666
aaaaaaaaaaaaaaaaaa6666666666666666ddddd8888888888888888666666666666666999999999cccccccccbbbbbbbbbbbb6666666666666666666666666666
aaaaaaaaaaaaaaaaaa6666666666666666ddddd8888888888888888666666666666666999999999cccccccccbbbbbbbbbbbb6666666666666666666666666666
aaaaaaaaaaaaaaaaaa6666666666666666ddddd8888888888888888666666666666666999999999cccccccccbbbbbbbbbbbb6666666666666666666666666666
aaaaaaaaaaaaaaaaaa6666666666666666ddddd8888888888888888666666666666666999999999cccccccccbbbbbbbbbbbb6666666666666666666666666666
aaaaaaaaaaaaaaaaaa66666666666666666ddddd6688888888888888888666666669999999999ccccccccc9bbbbbbbbbbbbbbb66666666666666666666666666
aaaaaaaaaaaaaaaaaa66666666666666666ddddd6688888888888888888666666669999999999ccccccccc9bbbbbbbbbbbbbbb66666666666666666666666666
aaaaaaaaaaaaaaaaaa66666666666666666ddddd6688888888888888888666666669999999999ccccccccc9bbbbbbbbbbbbbbb66666666666666666666666666
aaaaaaaaaaaaaaaaaa66666666666666666ddddd6688888888888888888666666669999999999ccccccccc9bbbbbbbbbbbbbbb66666666666666666666666666
aaaaaaaaaaaaaaaaaa666666666666666666ddddd666668888888888888888666999999999cccccccccc96666bbbbbbbbbbbbbbbb66666666666666666666666
aaaaaaaaaaaaaaaaaa666666666666666666ddddd666668888888888888888666999999999cccccccccc96666bbbbbbbbbbbbbbbb66666666666666666666666
aaaaaaaaaaaaaaaaaa666666666666666666ddddd666668888888888888888666999999999cccccccccc96666bbbbbbbbbbbbbbbb66666666666666666666666
9a9a9a9a9a9a9a9a9a565656565656565656cdcdc656567878787878787878565989898989bcbcbcbcbc86565babababababababa65656565656565656565656
aaaaaaaaaaaaaaaaaaa666666666666666666dddddd6666668888888888888999999999ccccccccccc96666666bbbbbbbbbbbbbbbbb666666666666666666666
9a9a9a9a9a9a9a9a9a9656565656565656565dcdcdc6565658787878787878898989898cbcbcbcbcbc86565656ababababababababa656565656565656565656
aaaaaaaaaaaaaaaaaaa666666666666666666dddddd6666668888888888888999999999ccccccccccc96666666bbbbbbbbbbbbbbbbb666666666666666666666
9999999999999999999555555555555555555cccccc5555557777777777777888888888bbbbbbbbbbb85555555aaaaaaaaaaaaaaaaa555555555555555555555
aaaaaaaaaaaaaaaaaaa6666666666666666666dddddd6666666668888889999999999ccccccccccc666666666666bbbbbbbbbbbbbbbbb6666666666666666666
99999999999999999995555555555555555555cccccc5555555557777778888888888bbbbbbbbbbb555555555555aaaaaaaaaaaaaaaaa5555555555555555555
aaaaaaaaaaaaaaaaaaa6666666666666666666dddddd6666666668888889999999999ccccccccccc666666666666bbbbbbbbbbbbbbbbb6666666666666666666
99999999999999999995555555555555555555cccccc5555555557777778888888888bbbbbbbbbbb555555555555aaaaaaaaaaaaaaaaa5555555555555555555
9a9a9a9a9a9a9a9a9a9a5656565656565656565dcdcdc656565656568989898989bcbcbcbcbcbc565656565656565bababababababababa65656565656565656
999999999999999999995555555555555555555cccccc555555555558888888888bbbbbbbbbbbb555555555555555aaaaaaaaaaaaaaaaaa55555555555555555
9a9a9a9a9a9a9a9a9a9a5656565656565656565dcdcdc656565656568989898989bcbcbcbcbcbc565656565656565bababababababababa65656565656565656
999999999999999999995555555555555555555cccccc555555555558888888888bbbbbbbbbbbb555555555555555aaaaaaaaaaaaaaaaaa55555555555555555
9999999999999999999995555555555555555555ccccccc55555588888888888bbbbbbbbbbbb5555555555555555555aaaaaaaaaaaaaaaaaa555555555555555
9999999999999999999995555555555555555555ccccccc55555588888888888bbbbbbbbbbbb5555555555555555555aaaaaaaaaaaaaaaaaa555555555555555
9999999999999999999995555555555555555555ccccccc55555588888888888bbbbbbbbbbbb5555555555555555555aaaaaaaaaaaaaaaaaa555555555555555
8989898989898989898985454545454545454545bcbcbcb54545487878787878abababababab4545454545454545454a9a9a9a9a9a9a9a9a9545454545454545
59999999999999999999995555555555555555555ccccccc5588888888888bbbbbbbbbbbb77775555555555555555555aaaaaaaaaaaaaaaaaa55555555555555
49898989898989898989894545454545454545454cbcbcbc4578787878787babababababa767654545454545454545459a9a9a9a9a9a9a9a9a45454545454545
59999999999999999999995555555555555555555ccccccc5588888888888bbbbbbbbbbbb77775555555555555555555aaaaaaaaaaaaaaaaaa55555555555555
48888888888888888888884444444444444444444bbbbbbb4477777777777aaaaaaaaaaaa6666444444444444444444499999999999999999944444444444444
559999999999999999999995555555555555555555cccccccc888888888bbbbbbbbbbbb77777777755555555555555555aaaaaaaaaaaaaaaaaaa555555555555
448888888888888888888884444444444444444444bbbbbbbb777777777aaaaaaaaaaaa666666666444444444444444449999999999999999999444444444444
559999999999999999999995555555555555555555cccccccc888888888bbbbbbbbbbbb77777777755555555555555555aaaaaaaaaaaaaaaaaaa555555555555
448888888888888888888884444444444444444444bbbbbbbb777777777aaaaaaaaaaaa666666666444444444444444449999999999999999999444444444444
4545898989898989898989898545454545454545454cbcbcbcb87878ababababababa767676767676745454545454545459a9a9a9a9a9a9a9a9a954545454545
4444888888888888888888888444444444444444444bbbbbbbb77777aaaaaaaaaaaaa66666666666664444444444444444999999999999999999944444444444
4545898989898989898989898545454545454545454cbcbcbcb87878ababababababa767676767676745454545454545459a9a9a9a9a9a9a9a9a954545454545
4444888888888888888888888444444444444444444bbbbbbbb77777aaaaaaaaaaaaa66666666666664444444444444444999999999999999999944444444444
444448888888888888888888884444444444444447777bbbbbbbbaaaaaaaaaaaaaa4444466666666666644444444444444499999999999999999994444444444
444448888888888888888888884444444444444447777bbbbbbbbaaaaaaaaaaaaaa4444466666666666644444444444444499999999999999999994444444444
444448888888888888888888884444444444444447777bbbbbbbbaaaaaaaaaaaaaa4444466666666666644444444444444499999999999999999994444444444
343438787878787878787878783434343434343437676babababaa9a9a9a9a9a9a94343456565656565634343434343434398989898989898989893434343434
4444444888888888888888888888444444444477777777bbbbbbbbbaaaaaaaaaa444444444666666666666444444444444449999999999999999999444444444
3434343878787878787878787878343434343467676767ababababaa9a9a9a9a9434343434565656565656343434343434348989898989898989898434343434
4444444888888888888888888888444444444477777777bbbbbbbbbaaaaaaaaaa444444444666666666666444444444444449999999999999999999444444444
3333333777777777777777777777333333333366666666aaaaaaaaa9999999999333333333555555555555333333333333338888888888888888888333333333
44444444488888888888888888888844444777777777777bbbbbbbbbaaaaaaa44444444444446666666666664444444444449999999999999999999944444444
33333333377777777777777777777733333666666666666aaaaaaaaa999999933333333333335555555555553333333333338888888888888888888833333333
44444444488888888888888888888844444777777777777bbbbbbbbbaaaaaaa44444444444446666666666664444444444449999999999999999999944444444
33333333377777777777777777777733333666666666666aaaaaaaaa999999933333333333335555555555553333333333338888888888888888888833333333
34343434343878787878787878787878676767676767679a9babababab9a9a343434343434343456565656565434343434343989898989898989898984343434
3333333333377777777777777777777766666666666666999aaaaaaaaa9999333333333333333355555555555333333333333888888888888888888883333333
34343434343878787878787878787878676767676767679a9babababab9a9a343434343434343456565656565434343434343989898989898989898984343434
3333333333377777777777777777777766666666666666999aaaaaaaaa9999333333333333333355555555555333333333333888888888888888888883333333
33333333333337777777777777777777776666666666999999aaaaaaaaaa33333333333333333333555555555533333333333888888888888888888888333333
33333333333337777777777777777777776666666666999999aaaaaaaaaa33333333333333333333555555555533333333333888888888888888888888333333
33333333333337777777777777777777776666666666999999aaaaaaaaaa33333333333333333333555555555533333333333888888888888888888888333333
232323232323276767676767676767676756565656568989899a9a9a9a9a23232323232323232323454545454523232323232878787878787878787878232323
3333333333333333777777777777777777776666699999999999aaaaaaaaaa333333333333333333355555555553333333333388888888888888888888333333
23232323232323236767676767676767676756565989898989899a9a9a9a9a232323232323232323254545454543232323232378787878787878787878232323
3333333333333333777777777777777777776666699999999999aaaaaaaaaa333333333333333333355555555553333333333388888888888888888888333333
22222222222222226666666666666666666655555888888888889999999999222222222222222222244444444442222222222277777777777777777777222222
43333333333333333377777777777777777777399999999999999aaaaaaaaaaa3333333333333333335555555555333333333388888888888888888888333333
32222222222222222266666666666666666666288888888888888999999999992222222222222222224444444444222222222277777777777777777777222222
43333333333333333377777777777777777777399999999999999aaaaaaaaaaa3333333333333333335555555555333333333388888888888888888888333333
32222222222222222266666666666666666666288888888888888999999999992222222222222222224444444444222222222277777777777777777777222222
3434232323232323232357676767676767676989898989898989892a9a9a9a9a9a23232323232323232545454545232323232378787878787878787878232323
33332222222222222222566666666666666668888888888888888829999999999922222222222222222444444444222222222277777777777777777777222222
3434232323232323232357676767676767676989898989898989892a9a9a9a9a9a23232323232323232545454545232323232378787878787878787878232323
33332222222222222222566666666666666668888888888888888829999999999922222222222222222444444444222222222277777777777777777777222222
22333332222222222555555566666666666888888888888888888222999999999999222222222222222244444444222222222777777777777777777777222222
22333332222222222555555566666666666888888888888888888222999999999999222222222222222244444444222222222777777777777777777777222222
22333332222222222555555566666666666888888888888888888222999999999999222222222222222244444444222222222777777777777777777777222222
12232322121212121545454556565656565878787878787878787212898989898989121212121212121234343434121212121767676767676767676767121212
22222333332222255555555555666666688888888888888888822222229999999999999222222222222244444444222222222777777777777777777777222222
12121323231212154545454545565656587878787878787878721212128989898989898212121212121234343434121212121767676767676767676767121212
22222333332222255555555555666666688888888888888888822222229999999999999222222222222244444444222222222777777777777777777777222222
11111222221111144444444444555555577777777777777777711111118888888888888111111111111133333333111111111666666666666666666666111111
22222222233355555555555552222668888888888888888882222222222299999999999992222222222244444444222222222777777777777777777777222222
11111111122244444444444441111557777777777777777771111111111188888888888881111111111133333333111111111666666666666666666666111111
22222222233355555555555552222668888888888888888882222222222299999999999992222222222244444444222222222777777777777777777777222222
11111111122244444444444441111557777777777777777771111111111188888888888881111111111133333333111111111666666666666666666666111111
12121212124545454545454212121878787878787878787856521212121219898989898989821212121234343432121212126767676767676767676762121212
11111111114444444444444111111777777777777777777755511111111118888888888888811111111133333331111111116666666666666666666661111111
12121212124545454545454212121878787878787878787856521212121219898989898989821212121234343432121212126767676767676767676762121212
11111111114444444444444111111777777777777777777755511111111118888888888888811111111133333331111111116666666666666666666661111111
11111111444444444444211111177777777777777777775555555111111111188888888888888111111333333311111111116666666666666666666611111111
11111111444444444444211111177777777777777777775555555111111111188888888888888111111333333311111111116666666666666666666611111111
11111111444444444444211111177777777777777777775555555111111111188888888888888111111333333311111111116666666666666666666611111111
01010101343434343434110101076767676767676767674545454101010101087878787878787101010323232301010101015656565656565656565601010101
11111144444444444111222227777777777777777777755555555555111111111888888888888881113333333111111111166666666666666666666611111111
01010134343434343101121217676767676767676767654545454545010101010878787878787871012323232101010101065656565656565656565601010101
11111144444444444111222227777777777777777777755555555555111111111888888888888881113333333111111111166666666666666666666611111111
00000033333333333000111116666666666666666666644444444444000000000777777777777770002222222000000000055555555555555555555500000000
11114444444444411111111177777777777777777777555555555555555111111188888888888888883333311111111111666666666666666666666111111111
00003333333333300000000066666666666666666666444444444444444000000077777777777777772222200000000000555555555555555555555000000000
11114444444444411111111177777777777777777777555555555555555111111188888888888888883333311111111111666666666666666666666111111111
00003333333333300000000066666666666666666666444444444444444000000077777777777777772222200000000000555555555555555555555000000000
01343434343431010101016767676767676767676701054545454545454545010101787878787878787821010101010106565656565656565656510101010109
00333333333330000000006666666666666666666600044444444444444444000000777777777777777720000000000005555555555555555555500000000008
01343434343431010101016767676767676767676701054545454545454545010101787878787878787821010101010106565656565656565656510101010109
00333333333330000000006666666666666666666600044444444444444444000000777777777777777720000000000005555555555555555555500000000008
03333333333000000000066666666666666666666000000044444444444444440000007777777777777777000000000055555555555555555555000000000088
03333333333000000000066666666666666666666000000044444444444444440000007777777777777777000000000055555555555555555555000000000088
03333333333000000000066666666666666666666000000044444444444444440000007777777777777777000000000055555555555555555555000000000088

