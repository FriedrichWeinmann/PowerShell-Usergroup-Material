#region Source
$source = @"
using System;

namespace Demo
{
    namespace Configuration
    {
        using System.Collections;

        [Serializable]
        public class Config
        {
            public static Hashtable Cfg = new Hashtable();

            public string Name;
            public string Module;
            public string Type
            {
                get { return Value.GetType().FullName; }
                set { }
            }
            public Object Value;
            public bool Hidden = false;
        }
    }

    namespace Shell
    {
        public enum StatusType
        {
            Info,

            Success,

            Warning,

            Failure
        }
    }

    namespace Shell.Parameters
    {
        using System.Text.RegularExpressions;

        [Serializable]
        public class MilkParameter
        {
            public int Value;
            public string ValueText;

            public MilkParameter(string Value)
            {
                string temp = Value.Trim();

                if (Regex.IsMatch(temp, "%$"))
                {
                    ValueText = temp;
                    try { this.Value = int.Parse(Regex.Matches(temp, "\\d+")[0].Value); }
                    catch { }
                }
                else
                {
                    ValueText = temp;
                }
            }

            public MilkParameter(int Value)
            {
                this.Value = Value;
                switch (Value)
                {
                    case 1:
                        ValueText = "wenig";
                        break;
                    case 2:
                        ValueText = "mittel";
                        break;
                    case 3:
                        ValueText = "viel";
                        break;
                    default:
                        ValueText = String.Format("{0}ml", Value);
                        break;
                }
            }

            public override string ToString()
            {
                return ValueText;
            }
        }
    }

    namespace Utility
    {
        using System.Collections.Generic;
        using System.Management.Automation;

        [Serializable]
        public class Trainee
        {
            #region Statics
            public static List<Trainee> List = new List<Trainee>();

            public static Trainee GetRandom()
            {
                if (List.Count == 0){ throw new InvalidOperationException("No Trainee registered yet!"); }

                Random rnd = new Random();
                int num = rnd.Next(0, (List.Count - 1));
                return List[num];
            }
            #endregion Statics

            #region Fields & Properties
            public string Givenname;
            public string Surname;
            public string Handle;
            public DateTime DateOfBirth;
            public string Email;
            #endregion Fields & Properties

            #region Constructors
            public Trainee()
            {

            }

            public Trainee(string Handle)
            {
                foreach (Trainee temp in List)
                {
                    if (temp.Handle.ToLower() == Handle.ToLower())
                    {
                        this.Givenname = temp.Givenname;
                        this.Surname = temp.Surname;
                        this.Handle = temp.Handle;
                        this.DateOfBirth = temp.DateOfBirth;
                        this.Email = temp.Email;
                    }
                }

                if (String.IsNullOrEmpty(this.Handle)) { throw new PSArgumentException("Invalid Trainee! Handle not recognized."); }
            }

            public Trainee(string Givenname, string Surname, string Handle, DateTime DateOfBirth, string Email)
            {
                this.Givenname = Givenname;
                this.Surname = Surname;
                this.Handle = Handle;
                this.DateOfBirth = DateOfBirth;
                this.Email = Email;
            }
            #endregion Constructors
        }
    }
}
"@

Add-Type $Source
#endregion Source

# Cleanup
Remove-Variable "source"