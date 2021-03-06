
dim.gvector = function(x) x@dim

#' @export
"dim<-.gvector" = function(x,value) {
  if (prod(value) != length(x@vec)) stop("Wrong dimensions for this gvector")
  new("gvector",vec=x@vec, dim=value);
}

getGenericFun = function () 
{
  frame <- sys.parent()
  envir <- parent.frame()
  call <- sys.call(frame)
  localArgs <- FALSE
  if (exists(".Generic", envir = envir, inherits = FALSE)) 
    fname <- get(".Generic", envir = envir)
  else {
    localArgs <- identical(as.character(call[[1L]]), ".local")
    if (localArgs) 
      call <- sys.call(sys.parent(2))
    fname <- as.character(call[[1L]])
  }
  fdef <- get(fname, envir = envir)
  fdef
}

Ops.gvector.apply = function(e1,e2,fun) {
  n1 = length(e1@vec)
  n2 = length(e2@vec)
  i1 = 1:n1
  i2 = 1:n2
  if (n1 > n2) {
    if (n1 %% n2 != 0) {
      stop("Length of g-vectors dont match")
    }
    i2 = rep_len(i2, n1)
    d = e1@dim
  } else {
    if (n2 %% n1 != 0) {
      stop("Length of g-vectors dont match")
    }
    i1 = rep_len(i1, n2)
    d = e2@dim
  }
  vec = lapply(1:length(i1), function(i) {fun(e1@vec[[i1[i]]],e2@vec[[i2[i]]])} )
  new.gvector(vec,d)
}

Ops.gvector = function(e1,e2) {
  fun = getGenericFun()
  Ops.gvector.apply(e1,e2,fun)
}

Ops.gvector.other = function(e1,e2) {
  fun = getGenericFun()
  e1 = as.gvector(e1)
  e2 = as.gvector(e2)
  Ops.gvector.apply(e1,e2,fun)
}

setMethod("Ops", signature("gvector","gvector"), Ops.gvector)
setMethod("Ops", signature("gvector","ANY"), Ops.gvector.other)
setMethod("Ops", signature("ANY","gvector"), Ops.gvector.other)

print.gvector = function(object) {
  tp = sapply(object@vec, function(x) { class(x)[1] })
  dim(tp) = object@dim
  print(tp)
}

#' @export
setMethod("show", "gvector", print.gvector)

#' @export
setMethod("sum", "gvector", function(x,...) {
  if (length(x@vec) > 0) {
    ret = x@vec[[1]];  
    if (length(x@vec) > 1) {
      for (i in 2:length(x@vec)) {
        ret = ret + x@vec[[i]];
      }
    }
    if (length(list(...)) > 0) {
      ret + sum(...);
    } else {
      ret
    }
  } else {
    if (length(list(...)) > 0) {
      sum(...);
    } else {
      0
    }
  }
})

#' @export
setMethod("[", signature("gvector","numeric","missing"), function(x,i,j,...) {
  h = 1:length(x@vec)
  h = h[i]
  ndim = length(h);
  new.gvector(x@vec[h],ndim)
})

#' @export
setMethod("[", signature("gvector","logical","missing"), function(x,i,j,...) {
  h = 1:length(x@vec)
  h = h[i]
  ndim = length(h);
  new.gvector(x@vec[h],ndim)
})

#' @export
setMethod("[", signature("gvector","numeric","numeric"), function(x,i,j,...,drop=F) {
  h = 1:length(x@vec)
  dim(h) = x@dim
  h = h[i,j,...,drop=drop]
  ndim = dim(h);
  if (is.null(ndim)) ndim=length(h)
  new.gvector(x@vec[as.vector(h)],ndim)
})

#' @export
setMethod("[[", signature("gvector","numeric"), function(x,i,...) {
  x@vec[[i]]
})

#' @export
setMethod("[<-", signature("gvector","numeric","missing","ANY"), function(x,i,j,value) {
  if (class(value) != "gvector") {
    value = as.gvector(value)
  }
  h = 1:length(x@vec)
  h = h[i]
  y=x;
  if (length(h) == prod(dim(value))) {
    
    y@vec[h] = value@vec
  } else {
    if (prod(dim(value)) == 1)
    {
      for (i in h) y@vec[[i]] = value@vec[[1]]
    }
    else
      stop("Wrong size in [<-.gvector")
  }
  assign(deparse(substitute(x)), y, parent.frame())
})

#' @export
setMethod("[<-", signature("gvector","logical","missing","ANY"), function(x,i,j,value) {
  if (class(value) != "gvector") {
    value = as.gvector(value)
  }
  h = 1:length(x@vec)
  h = h[i]
  y=x;
  if (length(h) == prod(dim(value))) {
    
    y@vec[h] = value@vec
  } else {
    if (prod(dim(value)) == 1)
    {
      for (i in h) y@vec[[i]] = value@vec[[1]]
    }
    else
      stop("Wrong size in [<-.gvector")
  }
  assign(deparse(substitute(x)), y, parent.frame())
})

#' @export
setMethod("[<-", signature("gvector","numeric","numeric","ANY"), function(x,i,j,value) {
  if (class(value) != "gvector") {
    value = as.gvector(value)
  }
  h = 1:length(x@vec)
  dim(h) = dim(x)
  h = h[i,j]
  h = as.vector(h)
  y=x;
  if (length(h) == prod(dim(value))) {
    
    y@vec[h] = value@vec
  } else {
    if (prod(dim(value)) == 1)
    {
      for (i in h) y@vec[[i]] = value@vec[[1]]
    }
    else
      stop("Wrong size in [<-.gvector")
  }
  assign(deparse(substitute(x)), y, parent.frame())
})

mat.prod.gvector.apply = function(x,y) {
  if (length(x@dim) > 1) {
    i1 = prod(x@dim[-length(x@dim)])
    j1 = x@dim[length(x@dim)]
  } else {
    i1 = 1
    j1 = x@dim[1]
  }  
  if (length(y@dim) > 1) {
    i2 = prod(y@dim[-1])
    j2 = y@dim[1]
  } else {
    i2 = 1
    j2 = y@dim[1]
  }
  if (j1 != j2) stop("Non conforming matrices in %*%");
  w = expand.grid(i=1:i1,j=1:i2)
  w = lapply(1:nrow(w),function(i) w[i,,drop=F])
  xdim=c(x@dim[-length(x@dim)],y@dim[-1])
  if (length(xdim)<1) xdim=1
  new.gvector(
    lapply(w,function(a) {
      sum(x[a$i+((1:j1-1)*i1)] * y[1:j1 + j1*(a$j-1)])
    }),
    xdim
  )
}

mat.prod.gvector.other = function(x,y) mat.prod.gvector.apply(as.gvector(x),as.gvector(y))
setMethod("%*%",signature("gvector","gvector"), mat.prod.gvector.apply)
setMethod("%*%",signature("gvector","ANY"), mat.prod.gvector.other)
setMethod("%*%",signature("ANY","gvector"), mat.prod.gvector.other)

#' @export
t.gvector = function(x){
  if(length(x@dim)>2){
    stop("Only matrixes and vectors can be transposed.")
  }
  else if(length(x@dim)==1){
    l=length(x@vec)
    new.gvector(x@vec,c(1,l))
  }
  else{
    n=x@dim[1]
    m=x@dim[2]
    indexes = as.vector(t(matrix(seq(1,m*n),n,m)))
    new.gvector(sapply(1:(n*m), function(i) x@vec[indexes[i]]),dim=c(m,n))
  }
}

#' @export
solve.gvector = function(x) { # simple Gauss elimination algorithm
  d = dim(x)
  if (length(d) != 2) stop("x have to be a matrix in solve")
  if (d[1] != d[2]) stop("x have to be a square matrxint in solve")
  n = d[1]
  ret = V(diag(nrow=d))
  print(n)
  for (i in seq_len(n))
  {
    w = x[i,i] ^ -1
    #    print(ToC(x))
    #    print(ToC(ret))
    for (j in seq_len(n)) {
      x[i,j] = x[i,j] * w
      ret[i,j] = ret[i,j] * w
    }
    for( k in seq_len(n-i) + i)
    {
      w = x[k,i]
      for (j in seq_len(n)) {
        x[k,j] = x[k,j] - x[i,j] * w
        ret[k,j] = ret[k,j] - ret[i,j] * w
      }
    }
  }
  print(ToC(x))
  ret
}
