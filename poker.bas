function better_hand(h1 as _handrank,h2 as _handrank) as short
    dim i as short
    if h1.rank>h2.rank then return 1
    if h1.rank<h2.rank then return 2
    for i=1 to 5
        if h1.high(i)>h2.high(i) then return 1
        if h1.high(i)<h2.high(i) then return 2
    next
    return 0
end function



function player_eval(p() as _pokerplayer,i as short) as short
    dim as _handrank ph(4)
    dim as short pi(4),j,knowall,flag,pir,debug,stillin
    debug=2
    for j=1 to 4
        if p(j).fold=0 then stillin+=1
        pi(j)=j
        p(j).win=ace_highlo_eval(p(j).card(),1)
    next
    p(i).bet=0
    if p(i).fold=0 and p(i).win.rank^2/3*p(i).risk>p(i).pot*2 then p(i).bet+=1 'see
    if p(i).fold=0 and p(i).win.rank^2/3*p(i).risk>p(i).pot*3 then p(i).bet+=1 'raise
    'if debug=2 then dprint i &":"& p(i).win.rank*2 & ">" &p(i).risk-p(i).pot*2 
    
'    
'    for j=1 to 4
'        if j=i then 
'            knowall=1
'        else
'            knowall=0
'        endif
'        if p(j).fold=0 then ph(j)=ace_highlo_eval(p(j).card(),knowall)
'    next
'    do
'        flag=0
'        for j=1 to 3
'            if better_hand(ph(j),ph(j+1))=2 then
'                swap pi(j),pi(j+1)
'                swap ph(j),ph(j+1)
'                flag=1
'            endif
'        next
'    loop until flag=0
'    
'    for j=1 to 4 
'        if pi(j)=i then pir=j
'    next
'    p(i).bet=0
'    if debug=1 then dprint i &"thinks winner is:"&pir
'    if pir=i then 
'        'bet
'        p(i).bet=2
'    else
'        if p(i).rank+p(i).pot<p(i).risk then p(i).bet=1
'        if debug=1 then dprint abs(ph(pir).rank-ph(i).rank)&">"&p(i).pot+p(i).risk 
'    endif
'    if p(i).bet=1 and rnd_range(1,81)<p(i).rank^2 then p(i).bet=2
'    'print "Rank vs pot+risk for "&i &p(i).win.rank &"<"& p(i).pot+p(i).risk
'    'if p(i).win.rank<=p(i).pot+p(i).risk then p(i).bet=0
'    'DRAW STRING (400,i*pcards.cardheight),"rank:"&pi(1)&"-"&pi(2)&"-"&pi(3)&"-"&pi(4)&"myself"&p(i).win.rank &"."&p(i).win.high(1)
    return 0
end function

function ace_highlo_eval(c() as cards.cardid,knowall as short) as _handrank
    dim as _handrank h1,h2
    dim as short debug
    h1=poker_eval(c(),0,knowall)
    h2=poker_eval(c(),1,knowall)
    if debug=1 then print h1.rank ;":";h2.rank
    if better_hand(h1,h2)=1 then return h1
    return h2
end function
    
function _pokerplayer.firstempty() as short
    ci+=1
    return ci
end function

function swap_card(cardin() as cards.cardid) as short
    dim as short c,i,j,low,l
    dim hand as _handrank
    dim card(5) as cards.cardid
    dim cc(5) as _cardcount
    for i=1 to 5
        card(i)=cardin(i)
        if pcards.crank(card(i))=1 then pcards.setcardvalue card(i),14
    next
    
    'Got a strait, or a flush or a strait flush dont change. else, change lowest cc1 card
    hand=ace_highlo_eval(card(),1)
    if hand.rank=9 or hand.rank=5 or hand.rank=6 or hand.rank=7 then return 0
    for i=1 to 5
        if card(i)<>0 then
            cc(i).rank=pcards.crank(card(i))
            cc(i).no=1
            for j=i+1 to 5
                if pcards.crank(card(i))=pcards.crank(card(j)) and card(j)<>0 then 
                    cc(i).no+=1
                    cc(i).pos=i
                    card(j)=0
                endif
            next
            card(i)=0
        endif
    next
    low=15
    for i=1 to 5
        if cc(i).no=1 and cc(i).rank<low then
            low=cc(i).rank
            l=i
        endif
    next
    return l
end function


function sort_cards(card() as cards.cardid,knowall as short=0) as short
    dim as short i,flag,debug,start
    if knowall=0 then
        start=2
    else
        start=1
    endif
    do
    flag=0
    for i=start to 4
        if pcards.crank(card(i))>pcards.crank(card(i+1)) then
            swap  card(i) , card(i+1)
            flag=1
        endif
    next
    if debug=1 then print ".";
    loop until flag=0
    return 0
end function

function poker_eval(cardin() as cards.cardid, acehigh as short,knowall as short) as _handrank
    dim r as _handrank
    dim card(5) as cards.cardid
    dim cc(5) as _cardcount
    dim as short i,flag,debug,flush,strait,countpairs,j,start
    'take card 1, count how often others are there. 
    'Aces are wild would solve the high/lo problem (Just or=1 to every test)
    debug=1
    
    for i=1 to 5
        card(i)=cardin(i)
    next
    
    if acehigh=1 then
        for i=1 to 5
            if pcards.crank(card(i))=1 then pcards.setcardvalue(card(i))=14
        next
    else
        for i=1 to 5
            if pcards.crank(card(i))=14 then pcards.setcardvalue(card(i))=1
        next
    endif
    
    if knowall=1 then 
        start=1
    else
        start=2
    endif
    do
        flag=0
        for i=start to 4
            if pcards.crank(card(i))>pcards.crank(card(i+1)) then
                swap  card(i) , card(i+1)
                flag=1
            endif
        next
        
    loop until flag=0
    r.high(1)=pcards.crank(card(5))
    'Check if flush
    flush=1
    for i=start to 4
        if pcards.csuit(card(i))<>pcards.csuit(card(i+1)) then flush=0
    next
    strait=1
    for i=start to 4
        if pcards.crank(card(i))<>pcards.crank(card(i+1))-1 then strait=0
    next

    if strait=1 and flush=1 then r.rank=9
    if r.rank<>0 then return r
    
    for i=start to 5
        if card(i)<>0 then
            cc(i).rank=pcards.crank(card(i))
            cc(i).no=1
            for j=i+1 to 5
                if pcards.crank(card(i))=pcards.crank(card(j)) and card(j)<>0 then 
                    cc(i).no+=1
                    card(j)=0
                endif
            next
            card(i)=0
        endif
    next
    
    
    do
        flag=0
        for i=1 to 4
            if cc(i).no<cc(i+1).no then 
                swap cc(i),cc(i+1)
                flag=1
            endif
            
        next
    loop until flag=0
    do
        flag=0
        for i=1 to 4
            if cc(i).no=cc(i+1).no and cc(i).rank<cc(i+1).rank then
                swap cc(i),cc(i+1)
                flag=1
            endif
        next
    loop until flag=0
    
    for i=1 to 5
        r.high(i)=cc(i).rank
    next
    
    'Check four of a kind
    if cc(1).no=4 then
        r.rank=8
        
        return r
    endif
    
    if cc(1).no=3 and cc(2).no=2 then
        r.rank=7
        return r
    endif
    
    'Flush
    if flush=1 then 
        r.rank=6
        return r
    endif
    
    'Strait
    if strait=1 then
        r.rank=5
        return r
    endif
    
    if cc(1).no=3 then
        r.rank=4
        return r
    endif
    
    if cc(1).no=2 and cc(2).no=2 then
        r.rank=3
        return r
    endif
    
    if cc(1).no=2 then
        r.rank=2
        return r
    endif
    
    r.rank=1
    
    return r
    
end function

function poker_next(i as short,p() as _pokerplayer) as short
    do
        i+=1
        if i>4 then i=1
    loop until p(i).in=1
    return i
end function


function play_poker(st as short) as short
    dim card(52) as cards.cardid
    dim as short i,k,x,y,dealer,curcard,j,l,ci,pi,winner,move,debug,speedup
    dim p(4) as _pokerplayer
    debug=1
    dim rules as _pokerrules
    pcards.LoadCards("graphics/cards2.bmp")
    p(4).name=crew(1).n
    rules.bet=50
    rules.limit=5
    if st<0 then rules.limit=10
    rules.closed=1
    rules.swap=0
    
    dealer=rnd_range(1,4)
    for i=1 to 3
        pi=get_highestrisk_questguy(st)
        if debug=1 then dprint ""&pi
        if pi>0 then
            p(i).name=questguy(pi).n
            p(i).risk=questguy(pi).risk
            p(i).money=questguy(pi).money
            p(i).in=1
            questguy(pi).location=-2
        else
            p(i).in=1
            p(i).name=character_name(rnd_range(0,1))
            p(i).risk=rnd_range(3,9)
            p(i).money=200+rnd_range(50,440)
        endif
        dprint p(i).name &" joins the game."
    next
    p(4).in=1
    for i=1 to 52
        card(i)=i
    next
    pcards.shuffle card()
    
    dealer=rnd_range(1,4)
    curcard=1
    pi=dealer
    ci=1
    j=0   
    for k=1 to 5
        for i=1 to 4
            if pi=dealer then j+=1
            pi=poker_next(pi,p())
            p(pi).card(k)=card(curcard)
            curcard+=1
            draw_poker_table(p(),,,rules)
            
            If (ScreenEvent(@evkey)) then speedup=1
            If speedup=0 then sleep 120
        next
    next
    
    for l=1 to 4
        sort_cards(p(l).card(),0)
        
    next
    draw_poker_table(p(),,,rules)
    pi=dealer
'    for i=1 to 4
'        if pi=4 then
'            'Player swap card.
'            dprint "Do you want to swap a card(1-5,0 for none)"
'            j=val(keyin)
'            
'        else
'            j=swap_card(p(pi).card())
'        endif
'        
'        p(pi).pot=1
'        
'        if j>0 then 
'            dprint p(pi).name &" swaps card "&j
'            curcard+=1
'            p(pi).card(j)=card(curcard)
'            draw_poker_table(p(),,rules)
'
'        endif
'    next
    do
        cls
        pi=poker_next(pi,p())
        draw_poker_table(p(),,,rules)
        dprint ""
        if p(pi).fold=0 and p(pi).in=1 then
            if pi=4 then
                player_eval(p(),pi)
                move=menu("Your bet:/see(" & (highest_pot(p())-p(4).pot)*rules.bet & "Cr.)/raise(" & (highest_pot(p())+1-p(4).pot)*rules.bet & "Cr.)/fold","",24,2,1)
                if move=1 then p(4).bet=highest_pot(p())-p(4).pot
                if move=2 then p(4).bet=highest_pot(p())+1-p(4).pot
                if move=3 or move=-1 then p(4).fold=1
                player.money-=p(4).bet*rules.bet
                if player.money<0 then
                    dprint "You don't have the money."
                    p(4).fold=1
                    player.money+=p(4).bet*rules.bet
                endif
            else
                player_eval(p(),pi)
            endif
            if p(pi).bet=0 then 
                p(pi).fold=1
                dprint p(pi).name &" folds."
            endif
            if p(pi).bet>0 then
                if p(pi).bet+p(pi).pot>rules.limit then p(pi).bet=rules.limit-p(pi).pot
                if p(pi).pot+p(pi).bet>highest_pot(p()) then
                    dprint p(pi).name &" raises."
                else
                    dprint p(pi).name &" sees."
                endif
                p(pi).pot+=p(pi).bet
                p(pi).bet=0
            endif
        endif
        if pi=dealer then 
            winner=poker_winner(p())
            if winner=0 then
                for i=1 to 4
                    if p(i).fold=0 then p(i).pot=highest_pot(p())
                next
            endif
        endif
    loop until winner<>0
    cls
    draw_poker_table(p(),1,winner,rules)
    
    if winner=4 then
        dprint "you win "&(p(1).pot+p(2).pot+p(3).pot+p(4).pot)*rules.bet &" Cr."
        player.money+=(p(1).pot+p(2).pot+p(3).pot+p(4).pot)*rules.bet
    endif
    if winner>0 then dprint "Winner:"&p(winner).name
    if winner<0 then
        dprint "Tie"
        if winner=-3 or winner=-4 then 
            dprint "you win "&(p(1).pot+p(2).pot+p(3).pot+p(4).pot)*rules.bet/2 &" Cr."
            player.money+=(p(1).pot+p(2).pot+p(3).pot+p(4).pot)*rules.bet/2
        endif
    endif
    no_key=keyin
    for i=1 to lastquestguy
        if questguy(i).location=-2 then questguy(i).location=st
    next
    return 0
end function

function highest_pot(p() as _pokerplayer) as short
    dim as short i,h
    for i=1 to 4
        if p(i).fold=0 then
            if p(i).pot>h then h=p(i).pot
        endif
    next
    return h
end function


function poker_winner(p() as _pokerplayer) as short
    'Check if 3 have folded
    dim as short i,cfold,winner,cbet,stillin(4),cin,flag,tieat,debug,nop
    
    dim victory as _handrank
    for i=1 to 4
        if p(i).name<>"" then nop+=1
    next
    for i=1 to nop
        if p(i).fold=1 then 
            cfold+=1
        else
            cin+=1
            stillin(cin)=i
        endif
    next
    
    if cfold=nop-1 then return stillin(1)
    'Check if betting over
    for i=2 to cin
        if p(stillin(1)).pot<>p(stillin(i)).pot then return 0
    next
    
    if debug=1 then
        for i=1 to cin
            draw string(500,i*12),stillin(i) &":"&p(stillin(i)).win.rank &":"& p(stillin(i)).win.high(1)
        next
    endif
    
    
    do
        if debug=1 then dprint "Entering loop"
        if debug=1 then
            for i=1 to cin
                draw string(500,i*12),stillin(i) &":"&p(stillin(i)).win.rank &":"& p(stillin(i)).win.high(1)
            next
            sleep
        endif
        
        flag=0
        for i=1 to cin-1
            select case better_hand(p(stillin(i)).win,p(stillin(i+1)).win) 
                case 2
                    if debug=1 then dprint "swapping pos "&i
                    flag=1
                    'swap p(stillin(i)),p(stillin(i+1))
                    swap stillin(i),stillin(i+1)
                    exit for
                case 0
                    tieat=i
            end select
        next
        
        if debug=1 and flag=0 then dprint "Leaving loop"
    loop until flag=0
    for i=1 to cin
        p(stillin(i)).rank=i
    next
    if debug=1 then
        for i=1 to cin
            draw string(500,200+i*12),stillin(i) &":"&p(stillin(i)).win.rank &":"& p(stillin(i)).win.high(1)
        next
    endif
    
    if tieat=0 or tieat>1 then
        return stillin(1)
    else
        return -1
    endif
    return 0
    'Tie....
end function

    
    'find best hand
    
function draw_poker_table(p() as _pokerplayer,reveal as short=0,winner as short=0,r as _pokerrules) as short
    dim as short x,y,i,j,pot
    
    dim as string handnames(9)
    handnames(1)="high card"
    handnames(2)="pair"
    handnames(3)="two pair"
    handnames(4)="three of a kind"
    handnames(5)="strait"
    handnames(6)="flush"
    handnames(7)="full house"
    handnames(8)="four of a kind"
    handnames(9)="strait flush"
    
    display_ship(0)
    for i=1 to 4
        set__color(11,0)
        if p(i).in=1 then
            pot=pot+p(i).pot
            draw string (x,y+pcards.cardheight),p(i).name &" In Pot:"& p(i).pot*r.bet &"cr.",,font2,custom,@_col
            if p(i).fold=0 then
                for j=1 to 5
                    if p(i).card(j)>0 then 
                        if (i=4 or j>r.closed or reveal=1) then
                            pcards.drawCardfront x,y,p(i).card(j)
                        else
                            if p(i).card(j) mod 2=0 then
                                pcards.drawCardback x,y,1
                            else
                                pcards.drawCardback x,y,2
                            endif
                        endif
                        x+=pcards.cardwidth
                    endif
                next
            else
                for j=1 to 5
                    if p(i).card(j) mod 2=0 then
                        pcards.drawCardback x,y,1
                    else
                        pcards.drawCardback x,y,2
                    endif
                    x+=pcards.cardwidth/2
                next
            endif
            
            if (reveal=1 and p(i).fold=0) or i=4 then 
                set__color(15,0)
                if i=winner then set__color(c_gre,0)
                draw string (x,y+pcards.cardheight/2-_fh2/2)," ("& handnames(p(i).win.rank) &")",,font2,custom,@_col
            endif
            x=0
            y=y+pcards.cardheight+_fh2+2
        endif
    next
    set__color(15,0)
    draw string (7*pcards.cardwidth,4*(pcards.cardheight+_fh2)/2-_fh1/2), "Pot: "&credits(pot*r.bet) &" Cr.",,font1,custom,@_col
    set__color(11,0)
    return 0
end function