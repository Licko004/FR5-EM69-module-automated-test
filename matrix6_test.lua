m = 0; n = 0; h = 0
i = 7; j =4; k =1
while(h<k) do
while(n<j) do
while(m<i) do
Lin(TR1_TOP,10,-1,0,1,-0.002*m+56.254*n,32.803*m+-0.004*n,30*h+30*(1+1),0,0,0)
Lin(TR1_TOP,10,-1,0,1,-0.002*m+56.254*n,32.803*m+-0.004*n,30*h,0,0,0)
Lin(TR1_TOP,10,-1,0,1,-0.002*m+56.254*n,32.803*m+-0.004*n,30*h+30*(1+1),0,0,0)
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