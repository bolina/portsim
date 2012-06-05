function [bool] = CompareDates(datevecA, datevecB, precision)
%%Compares two dates at a specified level of precision. Returns true if the
%%dates match at that level of precision, otherwise, returns false

%Parameters
%datevecA - datevec of the first date
%datevecB - datevec of the second date
%precision - number of sequential elmenents that must match

    bool = true;
    %loop through each datevec up to the level of precision specified
    for i=1:precision
        %if contents do not match, set bool to false
        if (datevecA(i)~=datevecB(i))
            bool = false;
        end
    end
end