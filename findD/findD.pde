import java.math.BigInteger;

BigInteger euler = new BigInteger("3016");
BigInteger e = new BigInteger("3");
BigInteger one = new BigInteger("1");

BigInteger l1[] = {euler, one, BigInteger.ZERO};
BigInteger l2[] = {e, BigInteger.ZERO, one};

while (((l1[0].subtract(l2[0])).multiply((l1[0].divide(l2[0])))).compareTo(BigInteger.ZERO) > 0) {
  BigInteger l3[] = l2;
  BigInteger q = l1[0].divide(l2[0]);
  l2[0] = (l1[0].subtract(l2[0])).multiply(q);
  l2[1] = (l1[1].subtract(l2[1])).multiply(q);
  l2[2] = (l1[2].subtract(l2[2])).multiply(q);
  l1 = l3;
}
if (l1[2].compareTo(BigInteger.ZERO) < 0) {
 l1[2] = l1[2].add(euler); 
}
println("GCD = " + l1[0] + " K = " + l1[1] + " D = " + l1[2]);
