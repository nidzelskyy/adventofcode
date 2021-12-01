#include <iostream>
#include <sstream> // for int to string conversion

using namespace std;

// Utility function for integer to string conversion
string IntToString(int num)
{
    stringstream temp;
    temp << num;
    return temp.str();
}

// Given a value 'curr', this function returns the value
// that comes after 'curr' in the look-and-say seq.

string countAndSay(string curr)
{
  string result = ""; // To store the term after 'curr'
  int i = 0; // to iterate over 'curr'
  // Need to iterate over 'curr', and also count the
  // number of digits that occur in the same group

  while (i < curr.length())
  {
    int count = 1; // To store how many times a digit occured

    // inner while loop compares current digit and the next digit
    while ((i + 1 < curr.length()) && curr[i] == curr[i+1])
    {
      i++;
      count++;
    }
    // to append count to result, convert count to a string.
    string stringCount = IntToString(count);
    result += (stringCount + curr[i]);
    i++;
  }
  return result;

}

// driver code
int main()
{
  string number = "1321131112"; // first member is always 1
  int n = 50; // number of members to print in the sequence
  for (int i = 0; i < n; i++)
  {
    //cout << number << endl;
    number = countAndSay(number);
  }
  cout << number.length() << endl;
  return 0;
}
