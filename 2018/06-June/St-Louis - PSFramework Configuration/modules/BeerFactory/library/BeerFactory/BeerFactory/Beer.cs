using System;

namespace BeerFactory
{
    /// <summary>
    /// Class containing information on a beer
    /// </summary>
    public class Beer
    {
        /// <summary>
        /// Name of the brand
        /// </summary>
        public string Brand;

        /// <summary>
        /// The kind of beer this is.
        /// </summary>
        public BeerType Type;

        /// <summary>
        /// The size of the beer.
        /// </summary>
        public Container Size;

        /// <summary>
        /// Creates a blank beer object
        /// </summary>
        public Beer()
        {

        }

        /// <summary>
        /// Creates a filled in beer object
        /// </summary>
        /// <param name="Brand">The brand of the beer</param>
        /// <param name="Type">The kind of beer</param>
        /// <param name="Size">The size of the beer</param>
        public Beer(string Brand, BeerType Type, Container Size)
        {
            this.Brand = Brand;
            this.Type = Type;
            this.Size = Size;
        }
    }
}
