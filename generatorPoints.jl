using PyCall
@pyimport scipy.special as sp
type Legendre
  poly::Array{Float64}
  generatorPoints::Function
  generateYPoint::Function
  generateXPoint::Function
  qf::Integer
  sigma::Float64
  function Legendre(qf,sigma)
    this = new()
    this.qf = qf
    this.sigma = sigma
    this.poly = [Float64(pol )for pol in sp.legendre(qf, monic=true)]
    this.generatorPoints =  function (n)
      xs = sort([ this.generateXPoint() for i=1:n])
      ys = [this.generateYPoint(x) for x in xs]
      return xs,ys
    end
    this.generateXPoint = function ()
      return Float64(rand(Bool) ? rand() : -rand())
    end
    this.generateYPoint = function (x)
      if this.qf==0
          return one(x)
      elseif this.qf==1
          return(x)
      end

      p0 = one(x)
      p1 = x

      for i = 2:n
          p2 = ( (2i-1)*this.qf*p1 - (i-1)*p0 ) / i
          p0 = p1
          p1 = p2
      end

      return p1
    end
    return this
  end
end
