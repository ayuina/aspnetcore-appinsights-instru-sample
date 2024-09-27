using Azure.Storage.Blobs;
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
        private readonly BlobServiceClient _blobServiceClient;

        public WeatherForecastController(ILogger<WeatherForecastController> logger, IHttpClientFactory httpClientFactory, BlobServiceClient blobServiceClient)
        {
            _logger = logger;
            _httpClientFactory = httpClientFactory;
            _blobServiceClient = blobServiceClient;
        }

        [HttpGet(Name = "GetWeatherForecast")]
        public async Task<IEnumerable<WeatherForecast>> Get()
        {
            _logger.LogInformation("API: GetWeatherForecast");

            await CallHttpBin_RequestHeaderInspection();
            await CallStorageServiceAsync();

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

        private async Task CallStorageServiceAsync()
        {
            _logger.LogInformation("method start: {method}", nameof(CallStorageServiceAsync));

            var containers = _blobServiceClient.GetBlobContainersAsync().AsPages();
            await foreach (var page in containers)
            {
                foreach (var container in page.Values)
                {
                    _logger.LogInformation("container {container} is found", container.Name);
                }
            }
        }

    }
}
