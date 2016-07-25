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
      return Float64(sum([this.poly[i]*(x^(i-1)) for i = 1:length(this.poly)]) + ( rand(Bool)? rand(0.0:0.001:this.sigma) : -rand(0.0:0.001:this.sigma)))
    end

    return this
  end
end
