function  data=setscale( data , ffmax ,ffmin )

    for j=1:size(data,2)
        data(:,j)=-1+2*(data(:,j)-ffmin(j))/(ffmax(j)-ffmin(j));
    end

end

