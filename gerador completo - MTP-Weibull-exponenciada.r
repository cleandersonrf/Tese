#Função para gerar uma amostra a partir do modelo de tempo de promoção Weibull-exponenciada com determinados níveis de censura e fração de cura.

# 1 - Gerar os valores da distribuição Weibull-exponenciada a partir do método da transformação inversa

value_we = NULL
rweibull_we <- function(n,pforma1,pforma2,pscale){
  for (i in 1:n) {
    u <- runif(1)
    value_we[i]=(1/pscale)*((-log(1 - u^(1/pforma2)))^(1/pforma1))
  }
  return(value_we)
}

# 2 - A função mtp_exp_Weibull() é a que gera os dados

#n - tamanho da amostra
#u - variável indicando censura à direita
#pforma1 - parâmetro de forma 1
#pforma2 - parâmetro de forma 2
#pscale - parâmetro de escala
#beta0 - parâmetro ligado a fração de curados
#x0 - variável associada ao parâmetro beta0

mtp_exp_Weibull = function(n,u,pforma1,pforma2,pscale,beta,x0){ #função para gerar dados com %fc e %cens (obs.: se u=0 => %cens = 0)
  #1 passo
  X=matrix(c(x0),nrow=n)
  eta=X%*%beta
  theta=exp(eta)
  M=rpois(n, theta) 
  cens_u=runif(1)
  #cada valor i gerado (i=1,...n), corresponde a uma Bernoulli(thetai)
  #passo 2
  cens=runif(n,0,u)
  #passos 3,4, 5 e 6
  for(i in 1:n){
    if(M[i]==0){
      t[i]=max(cens)
      y[i]=t[i]
      d[i]=0
    }else{
      if(u!=0){
        t[i]= rweibull_we(1,pforma1,pforma2,pscale)
        y[i] = min(t[i], cens[i]) 
        d[i] = ifelse(t[i] < cens[i], 1, 0)
      }else{
        t[i]= rweibull_we(1,pforma1,pforma2,pscale)
        y[i] = t[i]
        d[i] = 1
      } } }
  Dc=matrix(c(y,d,X,M),nrow=n)
  Pcura=mean(M==0) #proporção de curados na amostra
  pc1 = sum(d==0 & M>0)/sum(M>0) #proporção de censuras dentre os susceptíveis
  pc2 = pc1*(1-Pcura)+Pcura
  return(list(Dc,Pcura,pc1,pc2))
}
