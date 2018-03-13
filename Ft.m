function force = Ft(y,s,phi)
    if s <= 125
        phitgt = 0;
    elseif s > 125
        phitgt = 15;
    end
    
    if phi <= phitgt
        force = 1500000;
    else
        force = -1000000;
    end

end