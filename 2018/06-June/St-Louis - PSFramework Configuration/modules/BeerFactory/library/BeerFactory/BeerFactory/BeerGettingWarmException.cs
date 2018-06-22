using System;
using System.Collections.Generic;
using System.Text;

namespace BeerFactory
{
    /// <summary>
    /// Truly terrible!
    /// </summary>
    public class BeerGettingWarmException : Exception
    {
        /// <summary>
        /// Creates an out of beer Exception
        /// </summary>
        /// <param name="Message"></param>
        public BeerGettingWarmException(string Message)
            : base(Message)
        { }

        /// <summary>
        /// Creates an out of beer Exception
        /// </summary>
        /// <param name="Message"></param>
        /// <param name="InnerException"></param>
        public BeerGettingWarmException(string Message, Exception InnerException)
            : base(Message, InnerException)
        { }
    }
}
