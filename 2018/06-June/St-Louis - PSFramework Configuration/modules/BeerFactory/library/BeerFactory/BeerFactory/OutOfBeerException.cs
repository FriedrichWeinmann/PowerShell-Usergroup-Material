using System;
using System.Collections.Generic;
using System.Text;

namespace BeerFactory
{
    /// <summary>
    /// The greatest disaster has occured!
    /// </summary>
    public class OutOfBeerException : Exception
    {
        /// <summary>
        /// Creates an out of beer Exception
        /// </summary>
        /// <param name="Message"></param>
        public OutOfBeerException(string Message)
            : base(Message)
        { }

        /// <summary>
        /// Creates an out of beer Exception
        /// </summary>
        /// <param name="Message"></param>
        /// <param name="InnerException"></param>
        public OutOfBeerException(string Message, Exception InnerException)
            : base(Message, InnerException)
        { }
    }
}
