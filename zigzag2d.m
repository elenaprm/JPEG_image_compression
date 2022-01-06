function v = zigzag2d(M)
    N = length(M(:,1));
    fmax = [ (1:N-1) (N*ones(1,N)) ];
    fmin = [ ones(1,N) (2:N) ];
    k = 0;
    v = [];
    for u = 2:N+N
        for r = fmin(u-1):fmax(u-1)
            c = u-r;
            k = k+1;
            if rem(u,2) == 0,
                v(k) = M(r,c);
            else
                v(k) = M(c,r);
            end
        end
    end
v = v';