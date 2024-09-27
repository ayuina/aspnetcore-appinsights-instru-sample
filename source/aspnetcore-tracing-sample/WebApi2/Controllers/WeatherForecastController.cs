using Microsoft.AspNetCore.Mvc;
using System.Net.Http;

namespace WebApi2.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WeatherForecastController : ControllerBase
    {
        private static readonly string[] Summaries = new[]
        {
            "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
        };

        private readonly ILogger<WeatherForecastController> _logger;
        private readonly IHttpClientFactory _httpClientFactory;

        public WeatherForecastController(ILogger<WeatherForecastController> logger, IHttpClientFactory httpClientFactory)
        {
            _logger = logger;
            _httpClientFactory = httpClientFactory;
        }

        [HttpGet(Name = "GetWeatherForecast")]
        public async Task<IEnumerable<WeatherForecast>> Get()
        {
            _logger.LogInformation("API: GetWeatherForecast");

            await CallHttpBin_RequestHeaderInspection();

            return Enumerable.Range(1, 5).Select(index => new WeatherForecast
            {
                Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
                TemperatureC = Random.Shared.Next(-20, 55),
                Summary = Summaries[Random.Shared.Next(Summaries.Length)]
            })
            .ToArray();
        }

        private async Task CallHttpBin_RequestHeaderInspection()
        {
            _logger.LogInformation("method start: {method}", nameof(CallHttpBin_RequestHeaderInspection));

            var client = _httpClientFactory.CreateClient();
            client.BaseAddress = new Uri("https://httpbin.org");
            var res = await client.GetAsync("/headers");

            if (!res.IsSuccessStatusCode)
            {
                _logger.LogWarning("error from httpbin: status = {status}, reason = {readon} ", res.StatusCode, res.ReasonPhrase);
                return;
            }

            var resjson = await res.Content.ReadFromJsonAsync<RequestHeaderInspectionResponse>();
            var tracedata = resjson!.headers
                .Select(kvp => $"{kvp.Key}: {kvp.Value}")
                .Aggregate((x, y) => $"{x}{Environment.NewLine}{y}");
            _logger.LogInformation("request header inspection: {requestheaders}", tracedata);

        }

        public class RequestHeaderInspectionResponse
        {
            public Dictionary<string, string> headers { get; set; }
        }

    }
}
