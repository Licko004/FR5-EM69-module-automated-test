m = 0; n = 0; h = 0
i = 8; j =4; k =1
while(h<k) do
while(n<j) do
while(m<i) do
Lin(TR2_BTM,10,-1,0,1,-0.286*m+-56.001*n,-32.573*m+0.000*n,30*h+30*(1+1),0,0,0)
Lin(TR2_BTM,10,-1,0,1,-0.286*m+-56.001*n,-32.573*m+0.000*n,30*h,0,0,0)
Lin(TR2_BTM,10,-1,0,1,-0.286*m+-56.001*n,-32.573*m+0.000*n,30*h+30*(1+1),0,0,0)
RegisterVar("number","m")
RegisterVar("number","n")
RegisterVar("number","h")
m = m+1
end
n = n+1; m = 0
end
m = 0; n = 0
h = h+1
end