function output = templookup(alt,temp)
    
    if alt <= 0
        alt = 0;
    end
    if alt >= 50000
        alt = 50000;
    end

    output = interp1(temp(:,1),temp(:,2),alt,'nearest');

end